import 'package:flutter/material.dart';
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
    final texto = whatsappController.text;
    if (texto.isEmpty) return;

    // Regex: Busca secuencias de 8 a 15 dígitos
    final regExp = RegExp(r'\d{8,15}');
    final matches = regExp.allMatches(texto);

    DateTime fechaBase = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day,
      selectedTime.hour, selectedTime.minute
    );

    int contador = 0;
    for (var match in matches) {
      String numero = match.group(0)!;
      // Autocompletar con 858 si es necesario (tu lógica de negocio)
      if (numero.length < 15 && !numero.startsWith("858")) {
         // Aquí podrías llamar a tu validador o autocompletador
         // numero = "8580000$numero"; 
      }

      // Cálculo de hora correlativa
      DateTime fechaItem = fechaBase;
      if (_isCorrelativeEnabled) {
        // Sumamos 30 segundos por cada item para simular lectura en tubo
        fechaItem = fechaBase.add(Duration(seconds: 30 * contador));
        contador++;
      }

      _tempQueue.add(CaravanaModel(
        caravana: numero,
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

    // LÓGICA DE AUTOCOMPLETADO
    // Si escribió solo el visual (ej: "51622384") y son menos de 15 dígitos...
    if (xNumeroFinal.length < 15) {
      // 1. Calculamos cuántos ceros faltan para llegar a 15 contando el prefijo 858
      // Estrategia Senior: Asumimos que si escribe poco, es el final de la caravana uruguaya
      
      // Opción A: Rellenar todo con ceros a la izquierda hasta 15
      // numeroFinal = numeroFinal.padLeft(15, '0'); 
      
      // Opción B (Mejor para UY): Agregar 858 + ceros de relleno
      // Quitamos el 858 si el usuario lo puso parcial (ej: "858123") para evitar "858858..."
      if (!xNumeroFinal.startsWith("858")) {
          // Rellenamos lo que falta para llegar a 12 dígitos (15 - 3 del prefijo)
          String sufijo = xNumeroFinal.padLeft(12, '0');
          xNumeroFinal = "858$sufijo";
      } else {
          // Si ya empezó con 858 pero le faltan números, rellenamos el final
          xNumeroFinal = xNumeroFinal.padRight(15, '0'); 
      }

    }

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

  /// 3. Eliminar de la cola
  void eliminarDeCola(int index) {
    _tempQueue.removeAt(index);
    notifyListeners();
  }

  /// 4. Confirmar todo (Pasa los datos al SnigHandler principal)
  void confirmarTodo(BuildContext context, SnigHandler mainHandler) {
    if (_tempQueue.isEmpty) return;

    // Usamos el método del handler principal (que ya ajustamos para recibir listas)
    // Asumo que tenés un método setCaravanas o addAll en tu SnigHandler/ApiService
    // Si no, hacemos un bucle aquí:
    for (var c in _tempQueue) {
       // mainHandler.apiService.addCaravana(c); // Ejemplo
       // O llamar a un metodo masivo:
    }
    // mainHandler.agregarListaMasiva(_tempQueue); (Ideal crear este método)

    Navigator.pop(context); // Volvemos a la pantalla principal
  }
}