// fronten_flutter/lib/models/caravana_models.dart
import 'package:intl/intl.dart';

class CaravanaModel {
  String caravana; // Los 15 dígitos (ej: 858000051983708)
  // String? vid; // Identificador visual (si existe) <!> creo que no va
  DateTime hf_lectura; // Fecha de la lectura
  bool esOk; // Para el "punteo" automático (comparar con PDF)
  String gia; // Gia realacionada a esta lectura
  bool seleccionada = false; // Para selección múltiple en la UI

  CaravanaModel({
    required this.caravana,
    // this.vid,z
    required this.hf_lectura,
    required this.gia,
    this.seleccionada = false,
    this.esOk = true
  });

  // Este método creará el formato [|A000...|] que pide el SNIG
  String toSnigFormat() {
    // Limpiamos la fecha para que quede DDMMYYYY
    String dia = hf_lectura.day.toString().padLeft(2, '0');
    String mes = hf_lectura.month.toString().padLeft(2, '0');
    String anio = hf_lectura.year.toString();

    // Limpiamos la hora para que sea HHMMSS
    String horaLimpia = DateFormat('HHmmss').format(hf_lectura);

    return "[|A000000$caravana|$dia$mes$anio|$horaLimpia|$gia|]";
  }

  // Método para crear un objeto a partir de un JSON
  factory CaravanaModel.fromJson(Map<String, dynamic> json) {
    return CaravanaModel(
      caravana: json['caravana'],
      hf_lectura: DateTime.parse(json['hf_lectura']),
      gia: json['gia'],
      esOk: json['esOk'],
      seleccionada: json['seleccionada'],
    );
  }

  // Nuevo constructor para desarmar la trama del SNIG 
  factory CaravanaModel.fromSnigString(String line, String giaPorDefecto) {
    // line = "[|A000000858000040110807|02072024|112630|C204416|]"
    
    // 1. Limpiamos los corchetes y dividimos por el separador |
    final cleanLine = line.replaceAll('[', '').replaceAll(']', '');
    final parts = cleanLine.split('|');
    
    // parts[1] debería ser "A000000858000040110807"
    // Le quitamos los primeros 7 caracteres ("A000000")
    String caravanaExtraida = parts[1].substring(7);

    // parts[2] es la fecha "02072024" (DDMMYYYY)
    String f = parts[2];
    int dia = int.parse(f.substring(0, 2));
    int mes = int.parse(f.substring(2, 4));
    int anio = int.parse(f.substring(4, 8));

    // parts[3] es la hora "112630" (HHMMSS)
    String h = parts[3];
    int hora = int.parse(h.substring(0, 2));
    int min = int.parse(h.substring(2, 4));
    int seg = int.parse(h.substring(4, 6));

    // parts[4] es el GIA "C204416"
    String giaExtraida = parts[4].isNotEmpty ? parts[4] : giaPorDefecto;

    return CaravanaModel(
      caravana: caravanaExtraida,
      hf_lectura: DateTime(anio, mes, dia, hora, min, seg),
      gia: giaExtraida,
      esOk: true,
      seleccionada: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caravana': caravana,
      'hf_lectura': hf_lectura.toIso8601String(),
      'gia': gia,
      'esOk': esOk,
      'seleccionada': seleccionada,
    };
  }
}




