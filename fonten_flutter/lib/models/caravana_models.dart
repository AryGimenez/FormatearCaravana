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
    // this.vid,
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
}
