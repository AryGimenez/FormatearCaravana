// fornten_flutter\lib\services\txt_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fonten_flutter/models/caravana_models.dart';
import 'package:fonten_flutter/services/base_service.dart';
import 'package:share_plus/share_plus.dart';

mixin TxtService on BaseService {
  
  
  
 
  /// Asume que cada línea es un EID diferente.
  Future<List<CaravanaModel>?> pickAndParseTxt() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'], // Solo archivos .txt
        withData: true, // Es para que la carga de archivos funcione en web
      );

      if (result != null) { // Si el usuario selecciono un archivo...
        List<String> lines;
        
        // <!> Esot esta mal NO tranforma al formato correcto el formato que debe resibir es 
        // <!> [|A0000000858000040110807|02072024|112630|C204416|] 
        // <!> Asi es como son todos los archivos TXt si no tiene este formato esta mal puede variar que tengo otro campo igual pero ta.
        // <!> De eso teine que tranformarlo a // fonten_flutter\lib\screens\config_drawer\config_drawer.dart
        // <!> Ta caps abria que implmentra un metdo que se le pase el string entero y que el te entrege el objent

        if (kIsWeb) { // Detrmina si se ejecuta en web o en desktop
          // WEB ------
          final bytes = result.files.single.bytes!;
          final txtString = utf8.decode(bytes);
          lines = const LineSplitter().convert(txtString);
        } else {
          // DESKTOP ----
          final file = File(result.files.single.path!);
          lines = await file.readAsLines(); // <!>Esto no tiene sentido para mi  
        }

        return _mapLinesToCaravanas(lines);
      }
    } catch (e) {
      debugPrint("Error parseando TXT: $e");
    }
    return null;
  }


  /// Exporta la lista de caravanas dada a un archivo de texto.
  /// En Web dispara la descarga/share.
  /// En Desktop abre un diálogo para guardar el archivo.
  Future<void> exportarTxt(List<CaravanaModel> caravanas) async {
    if (caravanas.isEmpty) return;

    // <!> supongo que aca es que se jode aca es que teogo que madar 
    final content = caravanas.map((c) => c.toSnigFormat()).join('\n');
    final fileName = "caravanas_export.txt";

    try {
      if (kIsWeb) {
        // En Web usamos share_plus que suele manejar la descarga del blob
        final bytes = utf8.encode(content);
        final xFile = XFile.fromData(Uint8List.fromList(bytes),
            mimeType: 'text/plain', name: fileName);
        await Share.shareXFiles([xFile], text: 'Lista de Caravanas');
      } else {
        // En Desktop (Linux/Windows/Mac) usamos FilePicker.saveFile
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar TXT',
          fileName: fileName,
          allowedExtensions: ['txt'],
          type: FileType.custom,
        );

        if (outputFile != null) {
          // Asegurar extensión
          if (!outputFile.toLowerCase().endsWith('.txt')) {
            outputFile = "$outputFile.txt";
          }
          final file = File(outputFile);
          await file.writeAsString(content);
        }
      }
    } catch (e) {
      debugPrint("Error exportando TXT: $e");
    }
  }

  List<CaravanaModel> _mapLinesToCaravanas(List<String> lines) {
    List<CaravanaModel> resultado = [];
    
    for (var line in lines) {
      final text = line.trim();
      
      // Validamos que la línea tenga el formato mínimo esperado [|A...|...|]
      if (text.isNotEmpty && text.contains('|')) {
        try {
          // Usamos el nuevo constructor que creamos arriba
          resultado.add(CaravanaModel.fromSnigString(text));
        } catch (e) {
          // <!> Aca tendria que saltar un cartel de error para el fonte 
          // <!> O capas mejor para un log sentralizado
          debugPrint("Error al procesar línea: $text - Error: $e");
          // Si una línea está mal, la salteamos y seguimos con la otra
        }
      }
    }
    return resultado;
  }
}
