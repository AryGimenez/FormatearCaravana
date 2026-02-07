// fonten_flutter/lib/screens/snig/snig_handler.dart

import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';
import '../../services/api_service.dart';

enum CaravanaFilterType { todos, ok, faltantes }

/// Clase encargada de gestionar la lógica de negocio y el estado para el Formulario
/// prinsipal de la aplicacion snig.
///
/// Centraliza el procesamiento de caravanas, validaciones de formato uruguayo
/// y la notificación de cambios a la UI mediante el patrón Observer.
/// La clase extiende de ChangeNotifier para permitir que los Widgets
/// se reconstruyan automáticamente cuando los datos cambien.
class SnigHandler extends ChangeNotifier {
  /// Instancia del ApiService para acceder a los datos de las caravanas.
  final ApiService _apiService = ApiService();

  /// Lista para filtrar las caravanas que se muestran en la UI.
  List<CaravanaModel> _filteredCaravanas = [];

  /// Se encarga de indicar si se esta cargando datos.
  bool _isLoading = false;

  /// Se encarga de indicar si se ha producido un error. Lo utiliso para mostrar
  /// mensaje de erro
  String? _errorMessage;

  /// Filtro activo seleccionado en la UI
  CaravanaFilterType _activeFilter = CaravanaFilterType.todos;

  /// Consulta de búsqueda actual
  String _currentSearchQuery = '';

  /// Constructor de la clase SnigHandler.
  ///
  /// Inicializa la lista filtrada con los datos del servicio.
  SnigHandler() {
    _filteredCaravanas = List.from(_apiService
        .getListCaravanas); // Inicializar la lista filtrada con los datos del servicio
  }

  /// Se encarga de indicar si se muestran las acciones de la barra inferior.
  bool _showBottomActions = true;

  /// Getters de showBottomActions
  bool get showBottomActions => _showBottomActions;

  /// Getter del filtro activo
  CaravanaFilterType get activeFilter => _activeFilter;

  /// Setters de showBottomActions
  void toggleBottomActions() {
    _showBottomActions = !_showBottomActions;
    notifyListeners();
  }

  /// Getters Caravanas Filtradas
  List<CaravanaModel> get caravanasFiltradas => _filteredCaravanas;

  /// Getters de isLoading
  bool get isLoading => _isLoading;

  /// Getters de errorMessage
  String? get errorMessage => _errorMessage;

  // <!> Aca podria crear una variable de lista caravanas y usarla para pasar los parametros
  /// Getters de totalCaravanas
  int get totalCaravanas => _apiService.getListCaravanas.length;

  /// Getters de totalCaravanasOk, esto quiere desir las caravanas que se en cuentran en el
  /// simulador cargado.
  int get totalCaravanasOk =>
      _apiService.getListCaravanas.where((c) => c.esOk).length;

  /// Getters de totalCaravanasFaltantes, esto quiere desir las caravanas que
  /// no se encuentran en el simulador cargado.
  int get totalCaravanasFaltantes =>
      _apiService.getListCaravanas.where((c) => !c.esOk).length;

  /// Getters de totalCaravanasSeleccionadas, esto quiere desir las caravanas que
  /// se seleccionaron en la UI.
  int get totalCaravanasSeleccionadas =>
      _apiService.getListCaravanas.where((c) => c.seleccionada).length;

  /// Elimina el Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refrescar la lista de caravanas desde el servicio.
  ///
  /// Este método se encarga de:
  /// 1. Actualizar la lista filtrada con los datos del servicio.
  /// 2. Notificar a la interfaz que los datos han cambiado.
  /// Refrescar la lista de caravanas desde el servicio.
  ///
  /// Este método se encarga de:
  /// 1. Actualizar la lista filtrada con los datos del servicio.
  /// 2. Notificar a la interfaz que los datos han cambiado.
  void refrescarDesdeService() {
    _applyFilters();
  }

  //<!> Esto es lo nuevo ver como lo adapto 
  // void refrescarDesdeService() {
  //   // Recarga la lista local desde la fuente de verdad (ApiService)
  //   _filteredCaravanas = List.from(_apiService.getListCaravanas);
  //   notifyListeners(); // ¡Esto es lo que redibuja la pantalla!
  // }

  /// Aplica los filtros actuales (búsqueda y tipo) a la lista original
  void _applyFilters() {
    List<CaravanaModel> temp = _apiService.getListCaravanas;

    // 1. Filtrar por búsqueda de texto
    if (_currentSearchQuery.isNotEmpty) {
      temp =
          temp.where((c) => c.caravana.contains(_currentSearchQuery)).toList();
    }

    // 2. Filtrar por tipo (Categoría)
    switch (_activeFilter) {
      case CaravanaFilterType.ok:
        temp = temp.where((c) => c.esOk).toList();
        break;
      case CaravanaFilterType.faltantes:
        temp = temp.where((c) => !c.esOk).toList();
        break;
      case CaravanaFilterType.todos:
        // No hacer nada
        break;
    }

    _filteredCaravanas = temp;
    notifyListeners();
  }

  /// Establece el filtro de tipo y actualiza la lista
  void setFilter(CaravanaFilterType type) {
    if (_activeFilter != type) {
      _activeFilter = type;
      _applyFilters();
    }
  }

  void agregarCaravana(CaravanaModel nueva) {
    try {
      _apiService.addCaravana(nueva);
      _apiService.addCaravana(nueva);
      _applyFilters();
    } catch (e) {
      print(e); //<!> Esto deberia tener un menu emergente
    }
  }

  void eliminarCaravana(int index) {
    // El index corresponde a la lista filtrada, debemos encontrar el objeto real
    final caravanaAEliminar = _filteredCaravanas[index];
    final realIndex = _apiService.getListCaravanas.indexOf(caravanaAEliminar);
    if (realIndex != -1) {
      _apiService.removeCaravana(realIndex);
      _apiService.removeCaravana(realIndex);
      _applyFilters();
    }
  }

  //<!> Aca iria la funcion modificar caravana disparada por el CardItem
  // Tengo que crear una interfas que me de un menu para esta accion
  void modificarCaravana(int index) {
    final caravanaAEliminar = _filteredCaravanas[index];
    final realIndex = _apiService.getListCaravanas.indexOf(caravanaAEliminar);
    if (realIndex != -1) {
      _apiService.removeCaravana(realIndex);
      _apiService.removeCaravana(realIndex);
      _applyFilters();
    }
  }

  void eliminarSeleccionadas() {
    //<!> Aca deberia llamar a el metdo eliminar caravana ademas de app service
    _apiService.getListCaravanas.removeWhere((c) => c.seleccionada);
    _apiService.getListCaravanas.removeWhere((c) => c.seleccionada);
    _applyFilters();
  }

  /// Cambia el estado de seleccionada de la caravana en la lista filtrada.
  ///
  /// Este método se encarga de:
  /// 1. Cambiar el valor de la propiedad [seleccionada] de la caravana en la lista filtrada.
  /// 2. Notificar a la interfaz que los datos han cambiado.
  void toggleSeleccion(int index) {
    //<!> Esto no tengo claro como funciona principalente en que momenot ago que aparesca el boton elminar
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
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void filterCaravanas(String query) {
    _currentSearchQuery = query;
    _applyFilters();
  }

  /// Verifica si todas las caravanas mostradas están seleccionadas
  bool get areAllSelected {
    if (_filteredCaravanas.isEmpty) return false;
    return _filteredCaravanas.every((c) => c.seleccionada);
  }

  /// Alterna la selección de todas las caravanas mostradas
  void toggleSelectAll(bool? value) {
    if (value == null) return;
    for (var c in _filteredCaravanas) {
      c.seleccionada = value;
    }
    notifyListeners();
  }

  bool get isLoadingSimulador => _apiService.isLoadingSimulador;

  void descargarSimulador() {
    _apiService.descargarSimulador(); // O el método que uses
    notifyListeners();
  }



}
