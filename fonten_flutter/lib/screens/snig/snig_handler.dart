import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';
import '../../services/api_service.dart';

class SnigHandler extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  //<!> Esto no se para que lo tngo aca
  List<CaravanaModel> _filteredCaravanas = []; // Lista filtrada para la UI
  String _nroFormulario = "2680416";
  bool _isLoading = false;
  String? _errorMessage; // Para mostrar mensajes emergentes (Snackbars)

  SnigHandler() {
    // Inicializar la lista filtrada con los datos del servicio
    _filteredCaravanas = List.from(_apiService.caravanas);
  }

  // Getters
  List<CaravanaModel> get caravanas => _filteredCaravanas; //<!> Esto no lo tengo claro no entindo para qeu esta
  String get nroFormulario => _nroFormulario;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalEvaluados => _apiService.caravanas.length;
  int get totalOk => _apiService.caravanas.where((c) => c.esOk).length;
  int get totalFaltantes => _apiService.caravanas.where((c) => !c.esOk).length;
  int get selectedCount =>
      _apiService.caravanas.where((c) => c.seleccionada).length;

  void setNroFormulario(String value) {
    _nroFormulario = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // <!> Aca me falta como cargar el archivo no voe que este por ningun lado
  // Se que tengo que traerlo de snig_handler
  Future<void> cargarArchivoCsv() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevas = await _apiService.pickAndParseCsv();
      if (nuevas != null) {
        _apiService.clearCaravanas();
        for (var c in nuevas) {
          _apiService.addCaravana(c);
        }
        _filteredCaravanas = List.from(_apiService.caravanas);
      }
    } catch (e) {
      _errorMessage = "Error al cargar CSV: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void agregarCaravana(CaravanaModel nueva) {
    try {
      _apiService.addCaravana(nueva);
      _filteredCaravanas = List.from(_apiService.caravanas);
      notifyListeners();
    } catch (e) {
      print(e); //<!> Esto deberia tener un menu emergente
    }
  }

  void eliminarCaravana(int index) {
    // El index corresponde a la lista filtrada, debemos encontrar el objeto real
    final caravanaAEliminar = _filteredCaravanas[index];
    final realIndex = _apiService.caravanas.indexOf(caravanaAEliminar);
    if (realIndex != -1) {
      _apiService.removeCaravana(realIndex);
      _filteredCaravanas.removeAt(index);
      notifyListeners();
    }
  }

  void eliminarSeleccionadas() {
    //<!> Aca deberia llamar a el metdo eliminar caravana ademas de app service
    _apiService.caravanas.removeWhere((c) => c.seleccionada);
    _filteredCaravanas = List.from(_apiService.caravanas);
    notifyListeners();
  }

  /// Cambia el estado de seleccionada de la caravana en la lista filtrada.
  ///
  /// Este método se encarga de:
  /// 1. Cambiar el valor de la propiedad [seleccionada] de la caravana en la lista filtrada.
  /// 2. Notificar a la interfaz que los datos han cambiado.
  void toggleSeleccion(int index) { //<!> Esto no tengo claro como funciona principalente en que momenot ago que aparesca el boton elminar
    _filteredCaravanas[index].seleccionada =
        !_filteredCaravanas[index].seleccionada;
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
    _isLoading = true;
    notifyListeners();

    // Actualizamos la lista filtrada desde la fuente de verdad (ApiService)
    _filteredCaravanas = List.from(_apiService.caravanas);

    _isLoading = false;
    notifyListeners();
  }

  void filterCaravanas(String query) {
    if (query.isEmpty) {
      _filteredCaravanas = List.from(_apiService.caravanas);
    } else {
      _filteredCaravanas = _apiService.caravanas.where((c) {
        // En CaravanaModel usamos .caravana para el número de 15 dígitos
        return c.caravana.contains(query);
      }).toList();
    }
    notifyListeners();
  }

}
