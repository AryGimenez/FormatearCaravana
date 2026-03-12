import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';

class EditCaravanaHandler extends ChangeNotifier {
  final CaravanaModel caravanaOriginal;
  
  // Función externa para validar si el EID ya existe en la lista principal
  final String? Function(String val) onValidateEID;

  // Controladores de texto y tiempo
  late TextEditingController caravanaController;
  late TextEditingController giaController;
  late TimeOfDay selectedTime;
  
  // Llave del formulario para validaciones
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Inicializa los datos basándose en la caravana que le pasaron
  EditCaravanaHandler({
    required this.caravanaOriginal,
    required this.onValidateEID,
  }) {
    caravanaController = TextEditingController(text: caravanaOriginal.caravana);
    giaController = TextEditingController(text: caravanaOriginal.gia);
    
    DateTime xHora = caravanaOriginal.hf_lectura;
    selectedTime = TimeOfDay(hour: xHora.hour, minute: xHora.minute);
  }

  // --- MÉTODOS DE ESTADO ---

  void updateTime(TimeOfDay newTime) {
    selectedTime = newTime;
    notifyListeners();
  }

  String? validarEID(String? val) {
    if (val == null || val.isEmpty) return "Requerido";
    // Llama a la función que le inyectamos desde afuera
    return onValidateEID(val); 
  }

  // --- ACCIONES ---

  void confirmar(BuildContext context) {
    if (formKey.currentState!.validate()) {
      // Si todo es válido, devolvemos los datos modificados a quien abrió el diálogo
      Navigator.pop(context, {
        'eid': caravanaController.text,
        'gia': giaController.text,
        'hora': selectedTime
      });
    }
  }

  void cancelar(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    caravanaController.dispose();
    giaController.dispose();
    super.dispose();
  }
}