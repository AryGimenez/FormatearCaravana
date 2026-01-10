// fonten_flutter/lib/screens/snig/snig_handler.dart
import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';
import '../../services/csv_service.dart';

class SnigHandler extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  /// Lista de caravanas cargadas desde el archivo CSV.
  List<Caravana> _caravanas = [];
  /// Lista de caravanas filtradas (para la UI).
  List<Caravana> _filteredCaravanas = [];
  String _nroFormulario = "2680416";
  bool _isLoading = false;

  // Getters
  List<Caravana> get caravanas => _caravanas;
  String get nroFormulario => _nroFormulario;
  bool get isLoading => _isLoading;

  int get totalEvaluados => _caravanas.length;
  int get totalOk => _caravanas.where((c) => c.esOk).length;
  int get totalFaltantes => _caravanas.where((c) => !c.esOk).length;

  void setNroFormulario(String value) {
    _nroFormulario = value;
    notifyListeners();
  }

  Future<void> cargarArchivoCsv() async {
    _isLoading = true;
    notifyListeners();

    try {
      final nuevas = await _csvService.pickAndParseCsv();
      if (nuevas != null) {
        _caravanas = nuevas;
        _filteredCaravanas = List.from(_caravanas);
      }
    } catch (e) {
      // Aquí podrías manejar el error con un mensaje al usuario
      print("Error al cargar CSV: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void agregarCaravana(Caravana nueva) {
    _caravanas.add(nueva);
    _filteredCaravanas = List.from(_caravanas);
    notifyListeners();
  }

  void eliminarCaravana(int index) {
    _caravanas.removeAt(index);
    _filteredCaravanas = List.from(_caravanas);
    notifyListeners();
  }

  void eliminarSeleccionadas() {
    _caravanas.removeWhere((c) => c.seleccionada);
    _filteredCaravanas = List.from(_caravanas);
    notifyListeners();
  }

  void toggleSeleccion(int index) {
    _caravanas[index].seleccionada = !_caravanas[index].seleccionada;
    notifyListeners();
  }

  /// Obtiene y sincroniza la lista de caravanas.
  /// 
  /// Este método se encarga de:
  /// 1. Activar el estado de carga [_isLoading].
  /// 2. Clonar la lista original [_caravanas] hacia la lista filtrada [_filteredCaravanas].
  /// 3. Notificar a la interfaz que los datos han cambiado.
  /// 
  /// [Nota]: En el futuro, aquí se debe implementar la lectura desde la base de datos 
  /// local o el procesamiento del archivo CSV del SNIG.
  Future<void> fetchCaravanas() async {
    _isLoading = true; // Indica que se está cargando
    // notifyListeners(); // No es necesario si usas FutureBuilder

    // Aquí podrías cargar de una DB local en el futuro
    _filteredCaravanas = List.from(_caravanas);
    _isLoading = false;
    notifyListeners();
  }

  void filterCaravanas(String query) {
    if (query.isEmpty) {
      _filteredCaravanas = List.from(_caravanas);
    } else {
      _filteredCaravanas = _caravanas.where((c) {
        return c.eid.contains(query) || (c.vid?.contains(query) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  // Ejemplo de carga inicial (opcional)
  void cargarDatosEjemplo() {
    _caravanas = [
      Caravana(
          eid: "858000051983708",
          vid: "102",
          hora: "11:23:09",
          fecha: DateTime(2024, 7, 2),
          esOk: true),
      Caravana(
          eid: "858000051489744",
          vid: "114",
          hora: "09:45:00",
          fecha: DateTime(2024, 7, 2),
          esOk: false),
    ];
    _filteredCaravanas = List.from(_caravanas);
    notifyListeners();
  }
}
