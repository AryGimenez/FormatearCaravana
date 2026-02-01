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
  final TextEditingController eidController = TextEditingController();
  final TextEditingController giaController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  
  // Variables de tiempo
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // La Cola Temporal
  final List<CaravanaModel> _tempQueue = [];
  List<CaravanaModel> get tempQueue => _tempQueue;

  // Getters
  bool get isWhatsappExpanded => _isWhatsappExpanded;
  bool get isCorrelativeEnabled => _isCorrelativeEnabled;

  void toggleWhatsapp() {
    _isWhatsappExpanded = !_isWhatsappExpanded;
    notifyListeners();
  }

  void toggleCorrelative(bool value) {
    _isCorrelativeEnabled = value;
    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

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
    if (eidController.text.isEmpty) return;

    DateTime fechaFull = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day,
      selectedTime.hour, selectedTime.minute
    );

    _tempQueue.add(CaravanaModel(
      caravana: eidController.text,
      gia: giaController.text.isEmpty ? "S/D" : giaController.text,
      hf_lectura: fechaFull,
      seleccionada: false
    ));

    // Si es correlativa, avanzamos el reloj del formulario para el siguiente
    if (_isCorrelativeEnabled) {
       // Avanzamos 1 minuto la hora visual
       final nuevoTiempo = fechaFull.add(const Duration(minutes: 1));
       selectedTime = TimeOfDay.fromDateTime(nuevoTiempo);
    }

    eidController.clear(); // Limpiamos solo el numero para cargar el siguiente rapido
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