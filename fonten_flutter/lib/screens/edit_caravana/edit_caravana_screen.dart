// frontend/lib/screens/edit_caravana/edit_caravana_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_caravana_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/caravana_models.dart';

//class EditCaravanaScreen extends StatefulWidget {

class EditCaravanaScreen extends StatelessWidget {


  final CaravanaModel caravanaModel; // Caravana a modificar 
  
  // Función que le pedimos a la lógica para saber si el número ya existe
  // Retorna el mensaje de error o null si está todo bien
  final String? Function(String val) onValidateEID;

  const EditCaravanaScreen({
    super.key,
    required this.caravanaModel,
    required this.onValidateEID,
  });

  // @override
  // State<EditCaravanaScreen> createState() => _EditCaravanaScreenState();

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Handler específico para este diálogo
    return ChangeNotifierProvider(
      create: (_) => EditCaravanaHandler(
        caravanaOriginal: caravanaModel,
        onValidateEID: onValidateEID,
      ),
      child: const _EditCaravanaContent(),
    );
  }



}

// class _EditCaravanaScreenState extends State<EditCaravanaScreen> {

class _EditCaravanaContent extends StatelessWidget{

  // late TextEditingController _caravanaController;
  // late TextEditingController _giaController;
  // late TimeOfDay _selectedTime;
  
  final _formKey = GlobalKey<FormState>();


  // /// Inicia los componentes pasando por parametro la caravana a modificar <!> Mejorar Comentario
  // @override
  // void initState() { 
  //   super.initState();
  //   _caravanaController = TextEditingController(text: widget.caravanaModel.caravana);
  //   _giaController = TextEditingController(text: widget.caravanaModel.gia);
  //   DateTime xHora = widget.caravanaModel.hf_lectura;
  //   _selectedTime = TimeOfDay(hour: xHora.hour, minute: xHora.minute);
  // }

  // @override
  // void dispose() {
  //   _caravanaController.dispose();
  //   _giaController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // Dialog con fondo transparente para manejar nosotros el diseño
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 1. CABECERA VERDE ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppTheme.primary, // Tu verde oscuro
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Editar Caravana",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.edit_square, color: Colors.white70),
                ],
              ),
            ),

            // --- 2. FORMULARIO ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EID (Validado externamente)
                    _buildLabel("EID (Nº CARAVANA)"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _caravanaController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration(),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Requerido";
                        // Llamamos a la lógica externa para ver si es duplicado
                        return widget.onValidateEID(val);
                      },
                    ),
                    
                    const SizedBox(height: 16),

                    // FILA GIA Y HORA
                    Row(
                      children: [
                        // GIA
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("GIA / VID"),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _giaController,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                decoration: _inputDecoration(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // HORA
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("HORA"),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                                  if (time != null) setState(() => _selectedTime = time);
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                      const Icon(Icons.access_time, size: 20, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. BOTONES ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("CANCELAR", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Si todo es válido, devolvemos los datos crudos
                          Navigator.pop(context, {
                            'eid': _caravanaController.text,
                            'gia': _giaController.text,
                            'hora': _selectedTime
                          });
                        }
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text("CONFIRMAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey));
  
  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
    filled: true,
    fillColor: Colors.grey[50],
  );
}