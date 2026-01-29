import 'package:flutter/material.dart';
import 'package:fonten_flutter/services/api_service.dart';
import 'package:fonten_flutter/models/caravana_models.dart';

class ConfigDrawerHandler extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Se encarga de indicar si se ha producido un error. Lo utiliso para mostrar
  /// mensaje de erro
  String? _errorMessage; // <!> Esto creo que no va 

  /// Indica si se está cargando un archivo
  bool _isLoading = false; // <!> Esto creo que no va 

  /// Determina si el gia es editable
  bool isGiaEditEnabled = true;

  /// Determina si la fecha es editable
  bool isDateEditEnabled = true;

  /// Determina si la hora es editable
  bool isTimeEditEnabled = true;

  /// Gia seleccionado para la carga
  String _gia = "";

  /// Getter de gia
  String get gia => _gia;

  /// Fecha seleccionada para la carga
  DateTime _selectedDate = DateTime.now();

  /// Getter de selectedDate
  DateTime get selectedDate => _selectedDate;

  /// Hora seleccionada para la carga
  TimeOfDay _selectedTime = TimeOfDay.now();

  /// Getter de selectedTime
  TimeOfDay get selectedTime => _selectedTime;

  /// Setea el valor de isGiaEditEnabled
  void setGiaEditEnabled(bool value) {
    isGiaEditEnabled = value;
    notifyListeners();
  }

  /// Setea el valor de isDateEditEnabled
  void setDateEditEnabled(bool value) {
    isDateEditEnabled = value;
    notifyListeners();
  }

  /// Setea el valor de isTimeEditEnabled
  void setTimeEditEnabled(bool value) {
    isTimeEditEnabled = value;
    notifyListeners();
  }

  /// Setea el valor de selectedTime
  void setSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  /// Setea la fecha seleccionada
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Setea el valor de gia
  void setGia(String gia) {
    _gia = gia;
    notifyListeners();
  }

  Future<void> cargarArchivoCsv() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Solo notificamos que empezó a cargar (para el spinner)

    try {
      final List<CaravanaModel> xListCaravanas =
          await _apiService.pickAndParseCsv(); // Trae el archivo csv
      if (xListCaravanas.isNotEmpty) {
        

        // _apiService.addCaravana(pCaravana)

        for (CaravanaModel xCaravana in xListCaravanas) {
          // <!> Aca deberia pasar la lista entera y preguntar si quiero cargar o no las caravans repetidsas
          // <!> y trabajr con esas ecepciones
          _apiService.addCaravana(xCaravana);
        }
      }
    } catch (e) {
      _errorMessage = "Error al cargar CSV: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarArchivoPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevas = await _apiService.pickAndParseSimuladorPDF();
      if (nuevas.isNotEmpty) {
        
        for (var c in nuevas) {
          _apiService.addCaravana(c);
        }
      }
    } catch (e) {
      _errorMessage = "Error al cargar PDF: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // <!> Esto Tengo que sacarlo de aca va en config_drawer_handler
  Future<void> cargarArchivoTxt() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevas = await _apiService.pickAndParseTxt();
      if (nuevas != null && nuevas.isNotEmpty) {
        
        for (var c in nuevas) {
          _apiService.addCaravana(c);
        }
      }
    } catch (e) {
      _errorMessage = "Error al cargar TXT: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // <!> Esto Tengo que sacarlo de aca va en config_drawer_handler
  Future<void> exportarArchivoTxt() async {
    try {
      final seleccionadas =
          _apiService.getListCaravanas.where((c) => c.seleccionada).toList();

      if (seleccionadas.isEmpty) {
        _errorMessage = "No hay caravanas seleccionadas para exportar.";
        notifyListeners();
        return;
      }

      await _apiService.exportarTxt(seleccionadas);
    } catch (e) {
      _errorMessage = "Error al exportar TXT: $e";
      notifyListeners();
    }
  }

  void applyChanges() {
    // 1. Filtramos solo las que están seleccionadas
    var seleccionadas =
        _apiService.getListCaravanas.where((c) => c.seleccionada).toList();

    if (seleccionadas.isEmpty)
      return; // Si no hay seleccionadas, no hacemos nada

    // 2. Si vamos a cambiar la hora, definimos el punto de partida
    // <!> Esto no se si va 
    DateTime baseTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    for (int i = 0; i < seleccionadas.length; i++) {
      var caravana = seleccionadas[i];

      // --- LÓGICA DE GIA ---
      if (isGiaEditEnabled) {
        caravana.gia = gia; // El valor que viene del TextField
      }

      // --- LÓGICA DE FECHA Y HORA ---
      if (isDateEditEnabled || isTimeEditEnabled) {
        DateTime fechaOriginal = caravana.hf_lectura;

        int anio = isDateEditEnabled ? selectedDate.year : fechaOriginal.year;
        int mes = isDateEditEnabled ? selectedDate.month : fechaOriginal.month;
        int dia = isDateEditEnabled ? selectedDate.day : fechaOriginal.day;

        int hora = isTimeEditEnabled ? selectedTime.hour : fechaOriginal.hour;
        int min =
            isTimeEditEnabled ? selectedTime.minute : fechaOriginal.minute;

        // Creamos la nueva fecha
        DateTime nuevaFecha =
            DateTime(anio, mes, dia, hora, min, fechaOriginal.second);

        // Si la hora es masiva, sumamos 'i' minutos para que sean consecutivas
        if (isTimeEditEnabled) {
          nuevaFecha = nuevaFecha.add(Duration(minutes: i));
        }

        caravana.hf_lectura = nuevaFecha;
      }
    }

    // IMPORTANTE: Notificar a la UI que los datos cambiaron
    notifyListeners();
  }
}
