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
  /// Retorna una lista de [CaravanaModel] si el proceso es exitoso, o [null] si el usuario cancela.
  /// Lanza una excepción si ocurre un error durante la lectura o el parseo.
  Future<List<CaravanaModel>?> pickAndParseCsv() async {
    try {
      // Llama a la interfaz del sistema para seleccionar un archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // Restringe la selección a tipos específicos
        allowedExtensions: ['csv'], // Solo permite archivos con extensión .csv
        withData: true, // Indica que queremos los datos del archivo, se utiliza para web
      );

      if (result != null) {// Si el usuario no canceló la selección (result no es nulo)

        List<List<dynamic>> fields; // Lista de listas que contendrá los datos del CSV

        if (kIsWeb) { // Si es web no se puede acceder al path del archivo, por lo tanto se utilizan los bytes
          // Lógica para WEB: Usamos los bytes directamente
          final bytes = result.files.single.bytes!; // Obtiene los bytes del archivo
          final csvString = utf8.decode(bytes); // Decodifica los bytes a texto UTF-8
          fields = const CsvToListConverter().convert(csvString); // Convierte el texto plano a una estructura de Listas (filas y columnas)
        } else {
          // Lógica para MÓVIL/DESKTOP: Usamos el path
          final file = File(result.files.single.path!); // Obtiene la referencia al archivo físico mediante su ruta en el dispositivo
          final input = file.openRead(); // Abre un flujo de lectura (Stream) del archivo para no cargar todo en memoria de golpe
          fields = await input // Pipeline de transformación:
              .transform(utf8.decoder) // Decodifica los bytes a texto UTF-8
              .transform(const CsvToListConverter()) // Convierte el texto plano a una estructura de Listas (filas y columnas)
            .toList(); // Convierte el Stream en una lista final de datos crudos
        }

        return _mapFieldsToCaravanas(
            fields); // Envía los datos crudos al mapeador para convertirlos en objetos CaravanaModel
      }
    } catch (e) {
      //<!> Aca tendria que armar un log para pasarlo a un log sentralizado
      print("Error parseando CSV: $e"); // Registra el error en consola para depuración       rethrow; // Re-lanza el error para que el SnigHandler o la UI puedan capturarlo y mostrar un mensaje
    }
    return null; // Si el usuario cancela la selección, retorna nulo
  }

  /// Transforma los datos crudos del CSV (listas de listas) en una lista de objetos [CaravanaModel].
  ///
  /// Maneja la detección de cabeceras, el parseo de fechas y la asignación de valores
  /// por defecto para asegurar que la App no falle ante datos incompletos.
  List<CaravanaModel> _mapFieldsToCaravanas(List<List<dynamic>> fields) {
    List<CaravanaModel> caravanas = [];

    int startIndex =
        0; // Determina si la primera fila es una cabecera para ignorarla
    if (fields.isNotEmpty && fields[0].isNotEmpty) {
      // Si el archivo no está vacío y tiene al menos una fila
      String firstVal = fields[0][0].toString();
      if (firstVal.toLowerCase().contains("eid") || firstVal.isEmpty) {
        // Si contiene "eid" (común en Tru-Test) o está vacío, empezamos desde la fila 1
        startIndex =
            1; // <!> Creo que aca deberia corroborar que el formato sea el correcto si no salir porque agarre algo mal
        // <!> Para eso deberia prosesar la cabesera EID,VID,Date,Time,Custom
      }
    }

    for (var i = startIndex; i < fields.length; i++) {
      // Recorre cada fila del CSV a partir del índice definido
      final row = fields[i]; // Obtiene la fila actual
      if (row.length >= 1) {
        // Si la fila tiene al menos un valor
        // Formato Tru-Test esperado: EID, VID, Date, Time, Custom
        String xNumCaravana = row[0].toString();
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
        DateTime fecha;
        try {
          fecha = DateTime.parse("$xFecha $xHora");
        } catch (_) {
          fecha = DateTime.now();
        }
        //<!> Aca tengo que determinar si la caravana esta repetido que ago
        caravanas.add(CaravanaModel(
          // Agrega el modelo a la lista
          caravana: xNumCaravana, // Numero de caravana
          hf_lectura: fecha, // Fecha y hora de la lectura
          gia: xGia, // GIA
        ));
      } // Fin if
    } // Fin for
    return caravanas;
  }
}
