// fonten_flutter/lib/screens/carga_masiva/carga_masiva_handler.dart

import 'package:flutter/material.dart';
import 'package:fonten_flutter/services/api_service.dart';
import '../../models/caravana_models.dart';
import '../snig/snig_handler.dart'; // Importa el handler principal para pasarle los datos al final

// <!> Documetar codigo  no tengo ni ida que es esto !!!!!!!!!!!!!!!!!!!!!

//<DM!> Logica de formulario de agregar caravana 
// fUNCIONA MASIVANTE AGREGANDO CARABANAS EN UNA LISTA Y DANDOLA DE BAJA ADEMAS DE LA FUCIONALIDAD DE PASAR UAN CADENA DE TESTO PLANO DE CARAVANAS A UN CaravaanModel
class CargaMasivaHandler extends ChangeNotifier {
  // Estado de la UI
  bool _isWhatsappExpanded = false; // <!>  Esto no se que es 
  bool _isCorrelativeEnabled = true; // <!>  Esto no se que es 
  
  // Datos del Formulario
  final TextEditingController caravanaController = TextEditingController(); // <DM!> Controller Campo Editar Caravanas
  final TextEditingController giaController = TextEditingController(); // <DM!> Controller Campo Gia
  final TextEditingController whatsappController = TextEditingController(); // <DM!> Controller Campo WhatsApp
  
  // Variables de tiempo
  DateTime selectedDate = DateTime.now(); // <DM!> Guardo el valor de Fecha Lectura del formulario intresar
  TimeOfDay selectedTime = TimeOfDay.now(); // <DM!> Guardo el valor de Hora de la Caravana sociada a la lectrua 

  // La Cola Temporal
  final List<CaravanaModel> _tempQueue = [];
  List<CaravanaModel> get tempQueue => _tempQueue;

  // Getters
  bool get isWhatsappExpanded => _isWhatsappExpanded;
  bool get isCorrelativeEnabled => _isCorrelativeEnabled;
  
  // Variable para el error visual
  String? _caravanaErrorText;
  String? get caravanaErrorText => _caravanaErrorText;

  /// Valida el texto mientras el usuario escribe
  void validarInputCaravana(String valor) {
    if (valor.isEmpty) {
      _caravanaErrorText = null;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(valor)) {
      // Si contiene letras o símbolos
      _caravanaErrorText = "Debe ingresar solo valores numéricos";
    } else if (valor.length > 15) {
      // Si se pasó de largo
      _caravanaErrorText = "Máximo 15 dígitos";
    } else {
      // Si es corto (menos de 15) NO damos error, porque vamos a autocompletar
      _caravanaErrorText = null;
    }
    notifyListeners();
  }

  // <DM!> Creo que retrae y expande el menu que tiene un Text area
  // EN caso de retraido se expande y visebersa 
  void toggleWhatsapp() {
    _isWhatsappExpanded = !_isWhatsappExpanded;
    notifyListeners();
  }

  void toggleCorrelative(bool value) {
    _isCorrelativeEnabled = value;
    notifyListeners();
  }

  // <DM!> Actualizar campo fecha para asignarle a CaravanaModel 
  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

  // <DM!> Actualizar campo hora para asignarle a CaravanaModel 
  void updateTime(TimeOfDay newTime) {
    selectedTime = newTime;
    notifyListeners();
  }

  // --- LÓGICA DE NEGOCIO ---

  /// 1. Extraer desde el texto de WhatsApp
  void procesarTextoWhatsapp() {
    final texto = whatsappController.text; // Extrae el texto del campo de texto
    if (texto.isEmpty) return; // Si el texto esta vacio no hace nada

    // Regex: Busca secuencias de 8 a 15 dígitos
    final regExp = RegExp(r'\d{8,15}');
    final matches = regExp.allMatches(texto); // <DM!> Busca secuencias de 8 a 15 dígitos

  
    // Optiene la fecha ingresada en el formulario
    DateTime fechaBase = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day,
      selectedTime.hour, selectedTime.minute
    );

    int contador = 0;
    for (var match in matches) {
      String xNumCaravana = match.group(0)!;
      // Autocompletar con 858 si es necesario (tu lógica de negocio)

      xNumCaravana = _completarCaravana(xNumCaravana);

      // Cálculo de hora correlativa
      DateTime fechaItem = fechaBase;
      if (_isCorrelativeEnabled) {
        // Sumamos 30 segundos por cada item para simular lectura en tubo
        fechaItem = fechaBase.add(Duration(seconds: 30 * contador));
        contador++;
      }

      _tempQueue.add(CaravanaModel(
        caravana: xNumCaravana,
        gia: giaController.text.isEmpty ? "S/D" : giaController.text, // Sin Datos si está vacío
        hf_lectura: fechaItem,
        seleccionada: false
      ));
    }
    
    // Limpiamos el campo y cerramos el acordeón para ver la lista
    whatsappController.clear();
    _isWhatsappExpanded = false;
    notifyListeners();
  }

  /// 2. Agregar Manualmente
  void agregarManual() {
    // Si hay error visual (letras), no dejamos agregar
    if (_caravanaErrorText != null || caravanaController.text.isEmpty) return;

    String xNumeroFinal = caravanaController.text;  

    xNumeroFinal = _completarCaravana(xNumeroFinal);

    // <DM!> Creo el camp de fecha de CaravanaModel
    DateTime fechaFull = DateTime(
      selectedDate.year, // Año
      selectedDate.month, // Mes
      selectedDate.day, // Día
      // --------
      selectedTime.hour, // Hora
      selectedTime.minute // Minuto
    );
    // <!> Agrega a la lista CaravanaModel del formulario Es una lista independiete de la lista del sistema
    _tempQueue.add(CaravanaModel(
      caravana: xNumeroFinal, // Numero de caravana
      gia: giaController.text.isEmpty ? "S/D" : giaController.text, // Gia
      hf_lectura: fechaFull, // Fecha y hora
      seleccionada: false // Seleccionada
    ));

    // Si es correlativa, avanzamos el reloj del formulario para el siguiente. 
    if (_isCorrelativeEnabled) {
       // Avanzamos 1 minuto la hora visual
       // <!> Esto eta mal aca tengo que usar el metodo de App_Service
       
       // <!> Esto deberia ser aliairio no sliendo de un marco de minutos por la opertaiva del tuvo vos vas agregand 3 4 o 10 dependeido del tamanio del  y luego unos minutos y seguis leyendo talves podraims 
       final nuevoTiempo = fechaFull.add(const Duration(minutes: 1));
       selectedTime = TimeOfDay.fromDateTime(nuevoTiempo);
    }

    caravanaController.clear(); // Limpiamos solo el numero para cargar el siguiente rapido
    notifyListeners();
  }


  // <!> Para sacar version anterior 06/02/2024
  // String _completarCaravana(String pNumeroCaravana) {
  //   // LÓGICA DE AUTOCOMPLETADO
  //   // Si escribió solo el visual (ej: "51622384") y son menos de 15 dígitos...
  //   if (pNumeroCaravana.length < 15) {
  //     // 1. Calculamos cuántos ceros faltan para llegar a 15 contando el prefijo 858
  //     // Asumimos que si escribe poco, es el final de la caravana uruguaya
      
  //     // Opción B (Mejor para UY): Agregar 858 + ceros de relleno
  //     // Quitamos el 858 si el usuario lo puso parcial (ej: "858123") para evitar "858858..."
  //     if (!pNumeroCaravana.startsWith("858")) {
  //         // Rellenamos lo que falta para llegar a 12 dígitos (15 - 3 del prefijo)
  //         String sufijo = pNumeroCaravana.padLeft(12, '0');
  //         pNumeroCaravana = "858$sufijo";
  //     } else {
  //         // Si ya empezó con 858 pero le faltan números, rellenamos el final
  //         pNumeroCaravana = pNumeroCaravana.padRight(15, '0'); 
  //     }

  //   }
  //   return pNumeroCaravana;
  // }


  String _completarCaravana(String pNumeroCaravana) {
    // 1. Limpieza básica (por si se coló algún espacio)
    String xNumeroFinal = pNumeroCaravana.trim();

    // 2. Validación de contenido (Solo números)
    if (!RegExp(r'^[0-9]+$').hasMatch(xNumeroFinal)) {
      throw Exception("La caravana solo puede contener números.");
    }

    // 3. Validación de Longitud Excesiva
    if (xNumeroFinal.length > 15) {
      throw Exception("El número es demasiado largo (máximo 15 dígitos).");
    }

    // 4. Caso: Ya tiene 15 dígitos (Formato completo)
    if (xNumeroFinal.length == 15) {
      if (!xNumeroFinal.startsWith("858")) {
        throw Exception("Las caravanas de 15 dígitos deben comenzar con 858 (Uruguay).");
      }
      return xNumeroFinal; // Ya está correcta
    }

    // 5. Caso: Menos de 15 dígitos (Autocompletar)
    // Asumimos que lo que escribió es el VISUAL.
    // Rellenamos con ceros a la izquierda hasta completar los 12 dígitos del cuerpo.
    String cuerpo = xNumeroFinal.padLeft(12, '0');
    
    // Agregamos el prefijo país fijo
    return "858$cuerpo";
  }


  /// 3. Eliminar de la cola
  void eliminarDeCola(int index) {
    _tempQueue.removeAt(index);
    notifyListeners();
  }

  /// 4. Confirmar todo (Pasa los datos al SnigHandler principal)
  /// <!> Esto me falta programarlo pero deberia mandar todo al menu principal 
  void confirmarTodo(BuildContext context, SnigHandler mainHandler) {
    if (_tempQueue.isEmpty) return; // <DM!> Si la lista de caravanas temporal esta vais no hace nada 

    ApiService xApiService = ApiService();

    for (CaravanaModel xCaravana in _tempQueue) {
       xApiService.addCaravana(xCaravana);
    }
    // mainHandler.agregarListaMasiva(_tempQueue); (Ideal crear este método)

    Navigator.pop(context); // Volvemos a la pantalla principal
  }
}