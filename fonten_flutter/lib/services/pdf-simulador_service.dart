// fonten_flutter/lib/services/pdf-simulador_service.dart

import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:fonten_flutter/services/base_service.dart';
import 'package:fonten_flutter/models/caravana_models.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

mixin PdfSimuladorService on BaseService {


 Future<List<CaravanaModel>> pickAndParseSimuladorPDF() async {
    try {
      // Seleccionar el archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Importante para obtener los bytes
      );

      if (result == null) return []; // El usuario canceló la selección

      List<int> bytes;
      
      // Manejo de Web vs Mobile para obtener los bytes
      if (kIsWeb) {
        bytes = result.files.single.bytes!;
      } else {
        final file = File(result.files.single.path!);
        bytes = await file.readAsBytes();
      }

      // Extraer los números de caravana del PDF
      List<String> xListCaravansSimulador = await _leerCaravanasPDF(bytes);

      // Comparar con la lista actual y marcar las diferencias
      // Usamos la lista que ya tenés cargada en el BaseService (listCaravanas)
      return await _importSimuladorPDF(xListCaravansSimulador, listCaravanas);

    } catch (e) {
      // Re-lanzamos la excepción para que el Frontend la capture y muestre un cartel
      rethrow; 
    }
  }

 
  //<!> Revisar codio cuando vlaide el model para que solo asepte el fomatio apropiado
   Future<List<CaravanaModel>> _importSimuladorPDF(List<String> pListCaravansSimulador, List<CaravanaModel> pLisCaravanas ) async {

    // Comparamos y marcamos
    // Recorremos la lista de objetos que ya tenemos (la lectura del campo)
    for (CaravanaModel caravanaLectura in pLisCaravanas) {
      
      // Si el número de caravana de mi lista EXISTE en el PDF del simulador...
      
      if (!caravanaLectura.seleccionada) continue; // Si no esta seleccionada no la comparo
      
      
      
      
      if (caravanaLectura.caravana == "858000040110801") { //<!> Esto es temporal para probar la logica  
        print("Entro"); // Si no esta seleccionada no la comparo
      }


      if (pListCaravansSimulador.contains(caravanaLectura.caravana)) {  
        caravanaLectura.esOk = true; // Está todo bien, pertenece al DICOSE
      } else {
        // Si NO está en el PDF, es una de las que "no pertenecen" o tienen problemas
        caravanaLectura.esOk = false; 
      }

    }

    // Devolvemos la lista ya procesada
    return pLisCaravanas;
  }

  Future<List<String>> _leerCaravanasPDF(List<int> bytes) async {

    List<String> caravanasEncontradas = [];

    try {

        final PdfDocument document = PdfDocument(inputBytes: bytes); // Cargar el PDF

        // Extraer todo el texto del PDF
        String text = PdfTextExtractor(document).extractText();
        
        // IMPORTANTE: Liberar memoria del documento
        document.dispose();

        // VALIDACIÓN: ¿Es un simulador del SNIG?
        // Buscamos una frase que siempre esté en ese reporte
        if (!text.contains("SIMULACIÓN DE ANIMALES REGISTRADOS")) { 
          //<!> Aca hay abria que colocar una esepcion y lensala al fonten
          print("Error: El archivo no parece ser un reporte oficial del SNIG.");
          return []; // Retornamos lista vacía si no es el formato correcto
        }

        // EXTRACCIÓN CON REGEXP (Expresión Regular)
        // Las caravanas de Uruguay suelen tener 15 dígitos y empezar con 858
        // Esta es la forma más segura de sacarlas sin importar dónde estén en la tabla

        final regExp = RegExp(r'\b858\d{12}\b'); // Disiena el filtro para extraer las caravanas
        final matches = regExp.allMatches(text); // Busca todas las coincidenciasTe devuelve un Iterable (una colección de objetos tipo "Match")

        for (var match in matches) {
          String numero = match.group(0)!;
          // Evitamos duplicados si la caravana aparece dos veces
          if (!caravanasEncontradas.contains(numero)) {
            caravanasEncontradas.add(numero);
          }
        }

        return caravanasEncontradas;

      } catch (e) {
        //<!> Aca hay abria que colocar una esepcion y lensala al fonten 
        String xError = "Error procesando el PDF: $e";
        print(xError);

        throw ImportException(xError);
        
      }
  }

}