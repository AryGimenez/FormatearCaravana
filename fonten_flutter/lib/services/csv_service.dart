import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fonten_flutter/services/base_service.dart';
import '../models/caravana_models.dart';

enum DuplicadosStrategy {
  agregarTodos,      // Opción 1: Agrega duplicados y no duplicados
  soloNuevos,        // Opción 2: Solo agrega los que no existían
  cancelarSiHay      // Opción 3: Si detecta algún duplicado, no agrega nada
}

mixin CsvService on BaseService{

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
    // 1. Validaciones iniciales
    if (!file.path.endsWith('.csv')) throw ImportException("El archivo no es .csv");
    
    final lines = await file.readAsLines();
    if (lines.length < 2) 
      throw ImportException("Archivo vacío o sin cabecera.");

    List<CaravanaModel> xListNuevas = [];
    List<CaravanaModel> xDuplicadosEncontrados = [];

    // Optimizamos la búsqueda: Creamos un Set con los IDs existentes
    // Buscar en un Set es instantáneo, no importa si tenés 10 o 10.000 vacas.
    final eidsExistentes = listCaravanas.map((c) => c.caravana).toSet();

    // 2. Procesamiento de líneas
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
  // Future<List<Caravana>?> pickAndParseCsv() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['csv'],
  //     );

  //     if (result != null) {
  //       final file = File(result.files.single.path!);
  //       final input = file.openRead();
  //       final fields = await input
  //           .transform(utf8.decoder)
  //           .transform(const CsvToListConverter())
  //           .toList();

  //       return _mapFieldsToCaravanas(fields);
  //     }
  //   } catch (e) {
  //     print("Error parseando CSV: $e");
  //     rethrow;
  //   }
  //   return null;
  // }

  // List<Caravana> _mapFieldsToCaravanas(List<List<dynamic>> fields) {
  //   List<Caravana> caravanas = [];

  //   // Saltamos la cabecera si existe (asumiendo que la primera fila es cabecera si no es un EID)
  //   int startIndex = 0;
  //   if (fields.isNotEmpty && fields[0].isNotEmpty) {
  //     String firstVal = fields[0][0].toString();
  //     if (firstVal.toLowerCase().contains("eid") || firstVal.isEmpty) {
  //       startIndex = 1;
  //     }
  //   }

  //   for (var i = startIndex; i < fields.length; i++) {
  //     final row = fields[i];
  //     if (row.length >= 1) {
  //       // Formato Tru-Test esperado: EID, VID, Date, Time, Custom
  //       String eid = row[0].toString();
  //       String? vid = row.length > 1 ? row[1].toString() : null;
  //       String dateStr = row.length > 2 ? row[2].toString() : "";
  //       String timeStr = row.length > 3 ? row[3].toString() : "00:00:00";

  //       // Parsea la fecha (esperado YYYY-MM-DD o similar)
  //       DateTime fecha;
  //       try {
  //         fecha = DateTime.parse(dateStr);
  //       } catch (_) {
  //         fecha = DateTime.now(); // Fallback
  //       }

  //       caravanas.add(Caravana(
  //         eid: eid,
  //         vid: vid?.isEmpty == true ? null : vid,
  //         fecha: fecha,
  //         hora: timeStr,
  //       ));
  //     }
  //   }
  //   return caravanas;
  // }

}
