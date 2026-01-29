import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fonten_flutter/services/base_service.dart';
import '../models/caravana_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum DuplicadosStrategy {
  agregarTodos, // Opción 1: Agrega duplicados y no duplicados
  soloNuevos, // Opción 2: Solo agrega los que no existían
  cancelarSiHay // Opción 3: Si detecta algún duplicado, no agrega nada
}

mixin CsvService on BaseService {
  /// Importa una lista de caravanas desde un archivo [file] CSV.
  ///
  /// El parámetro [estrategia] define cómo manejar colisiones de EID:
  /// * [DuplicadosStrategy.agregarTodos]: No valida duplicados, mete todo el archivo.
  /// * [DuplicadosStrategy.soloNuevos]: Compara contra la lista actual y solo suma los EID inexistentes.
  /// * [DuplicadosStrategy.cancelarSiHay]: Si un solo EID ya existe en la lista, aborta la operación.
  Future<void> importarDesdeCsv(
    //<!> Creo que esto no lo estoy usando
    File file, {
    required DuplicadosStrategy estrategia,
  }) async {
    // Validaciones iniciales
    if (!file.path.endsWith('.csv'))
      throw ImportException("El archivo no es .csv");

    final lines = await file.readAsLines();
    if (lines.length < 2)
      throw ImportException("Archivo vacío o sin cabecera.");

    List<CaravanaModel> xListNuevas = [];
    List<CaravanaModel> xDuplicadosEncontrados = [];

    // Optimizamos la búsqueda: Creamos un Set con los IDs existentes
    // Buscar en un Set es instantáneo, no importa si tenés 10 o 10.000 vacas.
    final eidsExistentes = listCaravanas.map((c) => c.caravana).toSet();

    // Procesamiento de líneas
    for (var i = 1; i < lines.length; i++) {
      final data = lines[i].split(',');
      if (data.length < 5) continue; // Evita errores si una línea viene mal

      // Formato que se espara del csv
      //858000051105095,,2024-07-02,11:23:09,Pint
      final xCaravana = data[0].trim();
      final xFecha = data[2].trim();
      final xHora = data[3].trim();
      final xGia = data[4].trim();

      final nuevoModelo = CaravanaModel(
        caravana: xCaravana,
        gia: xGia,
        hf_lectura: DateTime.parse("$xFecha $xHora"),
      );

      if (eidsExistentes.contains(xCaravana)) {
        xDuplicadosEncontrados.add(nuevoModelo);
      } else {
        xListNuevas.add(nuevoModelo);
      }
    }

    // 3. Ejecución de la Estrategia (Mover los datos a la lista global)
    bool huboDuplicados = xDuplicadosEncontrados.isNotEmpty;

    switch (estrategia) {
      case DuplicadosStrategy.agregarTodos:
        listCaravanas.addAll(xListNuevas);
        listCaravanas.addAll(xDuplicadosEncontrados);
        break;

      case DuplicadosStrategy.soloNuevos:
        listCaravanas.addAll(xListNuevas);
        break;

      case DuplicadosStrategy.cancelarSiHay:
        if (!huboDuplicados) {
          listCaravanas.addAll(xListNuevas);
        }
        // Si hay duplicados, no agregamos NADA a listCaravanas
        break;
    }

    // 4. Notificar a la UI (opcional según donde esté el método)
    // notifyListeners();

    // 5. Siempre lanzamos la excepción si hubo duplicados,
    // DESPUÉS de haber hecho la inserción correspondiente.
    if (huboDuplicados) {
      throw ImportException(
        "Proceso finalizado con advertencias de duplicados.",
        caravanasDuplicadas: xDuplicadosEncontrados,
      );
    }
  }

  /// Abre el selector de archivos y parsea el CSV seleccionado
  ///
  /// Abre el selector de archivos del sistema para cargar un CSV y transformarlo en modelos de Caravana.
  ///
  /// Retorna una lista de [CaravanaModel] si el proceso es exitoso, 
  /// Lanza una excepción si ocurre un error durante la lectura o el parseo.
  Future<List<CaravanaModel>> pickAndParseCsv() async {
    List<CaravanaModel> xListCaravanas = [];
    try {
      // Llama a la interfaz del sistema para seleccionar un archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // Restringe la selección a tipos específicos
        allowedExtensions: ['csv'], // Solo permite archivos con extensión .csv
        withData:
            true, // Indica que queremos los datos del archivo, se utiliza para web
      );
      

      if (result == null)
        return xListCaravanas; // Si el usuario cancela la selección, retorna lista vacia

      List<List<dynamic>>
          fields; // Lista de listas que contendrá los datos del CSV
      
      String csvString;



      if (kIsWeb) {
        // Si es web no se puede acceder al path del archivo, por lo tanto se utilizan los bytes
        // Lógica para WEB: Usamos los bytes directamente
        final bytes =
            result.files.single.bytes!; // Obtiene los bytes del archivo
        csvString =
            utf8.decode(bytes); // Decodifica los bytes a texto UTF-8
        
        
        // fields = converter.convert(
        //     csvString); // Convierte el texto plano a una estructura de Listas (filas y columnas)
      } else {
        // Lógica para MÓVIL/DESKTOP: Usamos el path
        final file = File(result.files.single
            .path!); // Obtiene la referencia al archivo físico mediante su ruta en el dispositivo
        csvString = await file.readAsString(
            encoding: utf8); // Lee el archivo como texto UTF-8
        
      }

      fields = _procesarCsvManual(csvString);

      xListCaravanas = _mapFieldsToCaravanas(
          fields); // Envía los datos crudos al mapeador para convertirlos en objetos CaravanaModel
    } catch (e) {
      //<!> Aca tendria que armar un log para pasarlo a un log sentralizado
      print(
          "Error parseando CSV: $e"); // Registra el error en consola para depuración       rethrow; // Re-lanza el error para que el SnigHandler o la UI puedan capturarlo y mostrar un mensaje
    }
    return xListCaravanas; // Si el usuario cancela la selección, retorna nulo
  }

  /// Procesa un CSV manualmente, línea por línea, para manejar casos donde el conversor falla.
  List<List<dynamic>> _procesarCsvManual(String rawString) {
    // Dividimos el texto por cualquier tipo de salto de línea (Windows o Linux)
    List<String> lines = rawString.split(RegExp(r'\r?\n'));

    List<List<dynamic>> rows = [];
    for (var line in lines) {
      if (line.trim().isEmpty) continue; // Saltamos líneas vacías

      // Usamos el conversor solo para separar las comas de ESA línea
      var parsedLine = const CsvToListConverter().convert(line);
      if (parsedLine.isNotEmpty) {
        rows.add(parsedLine.first);
      }
    }
    return rows;
  }









  // <!> Creo que no va
  // // Método de apoyo por si el CSV viene sin saltos de línea claros
  // List<List<dynamic>> _reprocesarFilaUnica(List<dynamic> filaGigante) {
  //   // <!> Este creo que no va
  //   List<List<dynamic>> nuevasFilas = [];
  //   int columnasPorFila = 5; // EID, VID, Date, Time, Custom

  //   for (var i = 0; i < filaGigante.length; i += columnasPorFila) {
  //     var fin = (i + columnasPorFila < filaGigante.length)
  //         ? i + columnasPorFila
  //         : filaGigante.length;
  //     nuevasFilas.add(filaGigante.sublist(i, fin));
  //   }
  //   return nuevasFilas;
  // }







  /// Transforma los datos crudos del CSV (listas de listas) en una lista de objetos [CaravanaModel].
  ///
  /// Maneja la detección de cabeceras, el parseo de fechas y la asignación de valores
  /// por defecto para asegurar que la App no falle ante datos incompletos.
  List<CaravanaModel> _mapFieldsToCaravanas(List<List<dynamic>> fields) {
    // Formato que deberia resivir
    // 858000051105095,,2024-07-02,11:23:09,Pint 
    List<CaravanaModel> xListCaravanas = [];

    if (fields.isEmpty) return xListCaravanas; // Si no hay datos, retorna lista vacia
    
    // 1. VALIDACIÓN DE ARCHIVO CORRECTO
    // Verificamos si la primera celda contiene "EID" (estándar de Tru-Test)
    String firstCell = fields[0].isNotEmpty ? fields[0][0].toString().toUpperCase() : "";
    
    // Formato Tru-Test esperado: EID, VID, Date, Time, Custom
    if (!firstCell.contains("EID")) {
      // Si no es un archivo de lectura, lanzamos una excepción para avisar a la UI
      throw FormatException("El archivo seleccionado no tiene el formato de lectura Tru-Test válido.");
    }

    

    for (var i = 1; i < fields.length; i++) { // Comienza desde la segunda fila (índice 1)
      // Recorre cada fila del CSV a partir del índice definido
      final row = fields[i]; // Obtiene la fila actual

      // Saltamos filas que estén totalmente vacías <!> Creo que no va porque el paso antrior elimina los espacion en blanco 
      if (row.isEmpty || row[0].toString().trim().isEmpty) continue;
    
      String xNumCaravana = row[0].toString().trim();
      // String? vid = row.length > 1 ? row[1].toString() : null; // El nuevo modelo no tiene VID
      String xFecha = row.length > 2
          ? row[2].toString()
          : ""; // Fecha en formato dd/MM/yyyy
      String xHora = row.length > 3
          ? row[3].toString()
          : "00:00:00"; // Hora en formato HH:mm:ss
      String xGia = row.length > 4
          ? row[4].toString()
          : ""; // Usaremos esto para 'gia' si está vacío

      // Parsea la fecha
      DateTime xHf_lectura;
      try {
        xHf_lectura = DateTime.parse("$xFecha $xHora");
      } catch (_) {
        xHf_lectura = DateTime.now();
      }
      //<!> Aca tengo que determinar si la caravana esta repetido que ago
      xListCaravanas.add(CaravanaModel(
        // Agrega el modelo a la lista
        caravana: xNumCaravana, // Numero de caravana
        hf_lectura: xHf_lectura, // Fecha y hora de la lectura
        gia: xGia, // GIA
      ));
      
    } // Fin for
    return xListCaravanas;
  }
}
