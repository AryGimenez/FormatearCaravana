// fonten_flutter/lib/screens/snig/snig_handler.dart

import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';
import '../../services/api_service.dart';

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

  /// Constructor de la clase SnigHandler.
  ///
  /// Inicializa la lista filtrada con los datos del servicio.
  SnigHandler() {
    _filteredCaravanas = List.from(_apiService
        .getListCaravanas); // Inicializar la lista filtrada con los datos del servicio
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

  void setGia(String gia) {
    _apiService.gia = gia;
    // notifyListeners(); //<!> Sacar si no es necesario
  }


  void agregarCaravana(CaravanaModel nueva) {
    try {
      _apiService.addCaravana(nueva);
      _filteredCaravanas = List.from(_apiService.getListCaravanas);
      notifyListeners();
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
      _filteredCaravanas.removeAt(index);
      notifyListeners();
    }
  }

  //<!> Aca iria la funcion modificar caravana disparada por el CardItem
  // Tengo que crear una interfas que me de un menu para esta accion
  void modificarCaravana(int index) {
    final caravanaAEliminar = _filteredCaravanas[index];
    final realIndex = _apiService.getListCaravanas.indexOf(caravanaAEliminar);
    if (realIndex != -1) {
      _apiService.removeCaravana(realIndex);
      _filteredCaravanas.removeAt(index);
      notifyListeners();
    }
  }

  void eliminarSeleccionadas() {
    //<!> Aca deberia llamar a el metdo eliminar caravana ademas de app service
    _apiService.getListCaravanas.removeWhere((c) => c.seleccionada);
    _filteredCaravanas = List.from(_apiService.getListCaravanas);
    notifyListeners();
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
    _filteredCaravanas = List.from(_apiService.getListCaravanas);

    _isLoading = false;
    notifyListeners();
  }

  void filterCaravanas(String query) {
    if (query.isEmpty) {
      _filteredCaravanas = List.from(_apiService.getListCaravanas);
    } else {
      _filteredCaravanas = _apiService.getListCaravanas.where((c) {
        // En CaravanaModel usamos .caravana para el número de 15 dígitos
        return c.caravana.contains(query);
      }).toList();
    }
    notifyListeners();
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









// <!> Lo de abajo tengo que pasarlo a config_drawer_handler


  /// Determina si el gia es editable
  bool isGiaEditEnabled = true;

  /// Setea el valor de isGiaEditEnabled
  void setGiaEditEnabled(bool value) {
    isGiaEditEnabled = value;
    notifyListeners();
  }
  



  // <!> Aca me falta como cargar el archivo no voe que este por ningun lado
  // <!> Esto Tengo que sacarlo de aca va en config_drawer_handler
  // Se que tengo que traerlo de snig_handler
  Future<void> cargarArchivoCsv() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Solo notificamos que empezó a cargar (para el spinner)

    try {
      final nuevas = await _apiService.pickAndParseCsv(); // Trae el archivo csv
      if (nuevas != null && nuevas.isNotEmpty) {
        _apiService.clearCaravanas();

        // _apiService.addCaravana(pCaravana)

        for (var c in nuevas) {
          // <!> Aca deberia pasar la lista entera y preguntar si quiero cargar o no las caravans repetidsas
          // <!> y trabajr con esas ecepciones
          _apiService.addCaravana(c);
        }
        _filteredCaravanas = _apiService.getListCaravanas;
      }
    } catch (e) {
      _errorMessage = "Error al cargar CSV: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // <!> Esto Tengo que sacarlo de aca va en config_drawer_handler
  Future<void> cargarArchivoPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevas = await _apiService.pickAndParseSimuladorPDF();
      if (nuevas != null && nuevas.isNotEmpty) {
        _apiService.clearCaravanas();
        for (var c in nuevas) {
          _apiService.addCaravana(c);
        }
        _filteredCaravanas = _apiService.getListCaravanas;
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
        _apiService.clearCaravanas();
        for (var c in nuevas) {
          _apiService.addCaravana(c);
        }
        _filteredCaravanas = _apiService.getListCaravanas;
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

}
