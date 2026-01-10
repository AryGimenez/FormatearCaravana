import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fonten_flutter/services/base_service.dart';
import '../models/caravana_models.dart';

mixin CsvService on BaseService{






/// Importa caravanas desde un archivo.
  /// [file]: El archivo CSV seleccionado.
  /// [agregarRestantes]: Si es true, agrega las nuevas aunque haya duplicadas. 
  /// Si es false, si hay un solo duplicado, no agrega nada.
  Future<void> importarDesdeCsv(File file, {bool agregarRestantes = false}) async {
    List<CaravanaModel> nuevasProcesadas = [];
    List<String> duplicadosEncontrados = [];

    // 1. Validar extensión del archivo (Formato apropiado)
    if (!file.path.endsWith('.csv')) {
      throw ImportException("El archivo no tiene extensión .csv");
    }

    try {
      // 2. Leer líneas del archivo
      final lines = await file.readAsLines();
      
      // 3. Validar si el archivo está vacío o no tiene cabecera mínima
      if (lines.length < 2) {
        throw ImportException("El archivo está vacío o no tiene el formato correcto.");
      }

      // 4. Procesar líneas (Omitiendo cabecera)
      for (var i = 1; i < lines.length; i++) {
        final data = lines[i].split(','); // Asumiendo separador por coma
        
        // Validación de columnas mínimas (EID, VID)
        if (data.length < 2) continue; 

        final eid = data[0].trim();
        final vid = data[1].trim();

        // Verificar si ya existe en la lista global
        bool existe = listCaravanas.any((c) => c.eid == eid);

        if (existe) {
          duplicadosEncontrados.add(eid);
        } else {
          nuevasProcesadas.add(CaravanaModel(
            eid: eid, 
            vid: vid, 
            fecha: DateTime.now(), 
            esOk: true
          ));
        }
      }

      // 5. Lógica de decisión de inserción
      if (duplicadosEncontrados.isNotEmpty) {
        if (agregarRestantes) {
          // Agregamos las que no coinciden y avisamos de los duplicados
          listCaravanas.addAll(nuevasProcesadas);
          throw ImportException(
            "Se agregaron ${nuevasProcesadas.length} caravanas, pero ${duplicadosEncontrados.length} ya existían.",
            eidsDuplicados: duplicadosEncontrados
          );
        } else {
          // No agregamos nada y lanzamos error crítico
          throw ImportException(
            "Importación cancelada: Se encontraron duplicados.",
            eidsDuplicados: duplicadosEncontrados
          );
        }
      } else {
        // Todo limpio, agregamos todo
        listCaravanas.addAll(nuevasProcesadas);
      }

    } catch (e) {
      if (e is ImportException) rethrow;
      throw ImportException("Error al procesar el contenido del archivo: $e");
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
