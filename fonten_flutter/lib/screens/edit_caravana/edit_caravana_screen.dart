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

  /// Constructro 
  /// @param caravanaModel: Caravana a modificar 
  /// @param onValidateEID: Función que le pedimos a la lógica para saber si el número ya existe
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
      child: const _EditCaravanaContent(), //<!> Reaprar no se porque me da error 
    );
  }



}

// class _EditCaravanaScreenState extends State<EditCaravanaScreen> {

class _EditCaravanaContent extends StatelessWidget{
  const _EditCaravanaContent(); //<!> Reaprar no se porque me da error 
 
  // late TextEditingController _caravanaController;
  // late TextEditingController _giaController;
  // late TimeOfDay _selectedTime;
  
  // final _formKey = GlobalKey<FormState>();


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

    // Inyectamos el Handler específico para este diálogo
    final handler = context.watch<EditCaravanaHandler>();

    // Dialog con fondo transparente para manejar nosotros el diseño
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // // Define que el pop-up sea un rectángulo con las 4 esquinas redondeadas (16px)
      elevation: 0, // Elimina la sombra por defecto del Dialog
      backgroundColor: Colors.transparent, // Color de fondo transparente
      child: Container( // Contenedor principal
        decoration: BoxDecoration( // BoxDecoration: Define la apariencia del contenedor
          color: Colors.white, // Color blanco
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
          boxShadow: [ // Sombra
            BoxShadow( 
              color: Colors.black45, // Color de la sombra
              blurRadius: 20, // Desenfoque de la sombra
              offset: const Offset(0, 10)), // Posición de la sombra
          ],
        ), 
        child: Column( // Columna principal
          mainAxisSize: MainAxisSize.min, // Tamaño mínimo de la columna
          children: [
            // --- 1. CABECERA VERDE ---
            Container( 
              padding: const EdgeInsets.symmetric( // Padding: Espacio interno del contenedor
                horizontal: 20, // Padding horizontal
                vertical: 16 // Padding vertical
              ),
              decoration: const BoxDecoration(
                color: AppTheme.primary, // Tu verde oscuro
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Bordes redondeados
              ),
              child: Row( // Fila con el texto y el icono
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre el texto y el icono
                children:[// Elementos de la fila
                  Text(
                    "Editar Caravana",
                    style: TextStyle( // Estilo del texto
                      color: Colors.white, // Color del texto
                      fontSize: 18, fontWeight:  // Peso del texto
                      FontWeight.bold // Peso del texto
                      ), 
                  ),
                  Icon( // Icono de editar
                    Icons.edit_square, // Icono de editar
                    color: Colors.white70 // color del icono
                    ), 
                ],
              ),
            ),

            // --- 2. FORMULARIO ---
            Padding( // Padding: Espacio interno del contenedor
              padding: const EdgeInsets.all(20), // Padding: Espacio interno del contenedor
              child: Form( // Formulario
                key: handler.formKey, // Clave del formulario
                child: Column( // Columna con los campos del formulario
                  crossAxisAlignment: CrossAxisAlignment.start, // Alineación de los campos
                  children: [
                    // EID (Validado externamente)
                    _buildLabel("EID (Nº CARAVANA)"), // Etiqueta del campo
                    const SizedBox(height: 6), // Espacio entre el texto y el campo
                    TextFormField( // Campo de texto
                      controller: handler.caravanaController, // Controlador del campo
                      keyboardType: TextInputType.number, // Tipo de teclado
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Estilo del texto
                      decoration: _inputDecoration(), // Decoración del campo
                      validator: handler.validarEID, // El handler valida
                    ),
                    
                    const SizedBox(height: 16),

                    // FILA GIA Y HORA
                    Row(
                      children: [
                        // GIA
                        Expanded( 
                          child: Column( // Columna con los campos del formulario
                            crossAxisAlignment: CrossAxisAlignment.start, // Alineación de los campos
                            children: [
                              _buildLabel("GIA / VID"), // Etiqueta del campo
                              const SizedBox(height: 6), // Espacio entre el texto y el campo
                              TextFormField(
                                controller: handler.giaController, // Controlador del campo
                                style: const TextStyle(fontWeight: FontWeight.w600), // Peso del texto
                                decoration: _inputDecoration() // Decoración del campo
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12), // Espacio entre los campos
                        
                        // HORA
                        Expanded(
                          child: Column( // Columna con los campos del formulario
                            crossAxisAlignment: CrossAxisAlignment.start, // Alineación de los campos
                            children: [
                              _buildLabel("HORA"), // Etiqueta del campo
                              const SizedBox(height: 6), // Espacio entre el texto y el campo
                              InkWell( // InkWell: Permite hacer clic en el campo
                                onTap: () async { // onTap: Acción al hacer clic
                                
                                  final time = await showTimePicker( // showTimePicker: Muestra el selector de hora
                                    context: context, // Contexto
                                    initialTime: handler.selectedTime // Hora inicial
                                  );

                                  if (time != null) handler.updateTime(time); // Actualiza la hora
                                },
                                child: Container( // Container: Contenedor
                                  height: 48, // Altura del contenedor
                                  padding: const EdgeInsets.symmetric(horizontal: 12), // Padding horizontal
                                  decoration: BoxDecoration( // BoxDecoration: Decoración del contenedor
                                    border: Border.all( // Border: Borde
                                      color: Colors.grey.shade300, // Color del borde
                                      width: 2 // Ancho del borde
                                      ), 
                                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                  ),
                                  child: Row( // Row: Fila con los campos del formulario
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alineación de los campos
                                    children: [ // Elementos de la fila
                                      Text( // Text: Texto
                                        handler.selectedTime.format(context), // Formato de la hora
                                        style: const TextStyle( // Estilo del texto
                                          fontWeight: FontWeight.w600, // Peso del texto  
                                          fontSize: 16) // Tamaño del texto
                                      ),  
                                      const Icon( // Icono
                                        Icons.access_time, // Icono de hora
                                        size: 20, // Tamaño del icono
                                        color: Colors.grey) // Color del icono
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
            Padding( // Padding: Espaciado
              padding: const EdgeInsets.fromLTRB(
                  20, // Padding izquierdo
                  0, // Padding superior
                  20, // Padding derecho
                  20 // Padding inferior
                ),
              child: Row( // Row: Fila con los botones
                children: [ // Elementos de la fila
                  Expanded(
                    child: OutlinedButton( // OutlinedButton: Botón con borde
                      onPressed: () => handler.cancelar(context), // Acción al hacer clic
                      style: OutlinedButton.styleFrom( // Estilo del botón
                        padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertical
                        side: BorderSide( // Borde 
                          color: Colors.grey.shade300, // Color del borde
                          width: 2), // Ancho del borde
                        shape: RoundedRectangleBorder( // Forma del botón
                          borderRadius: BorderRadius.circular(12) // Bordes redondeados
                        ),
                      ),
                      child: Text( // Texto del botón
                        "CANCELAR", // Texto del botón
                        style: TextStyle( // Estilo del texto
                          color: Colors.grey[600], // Color del texto
                          fontWeight: FontWeight.bold // Peso del texto
                        )
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => handler.confirmar(context),
                      icon: const Icon( // Icono 
                        Icons.check_circle, // Icono de check
                        color: Colors.white // Color blanco
                        ),
                      label: const Text(
                        "CONFIRMAR", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold
                          )
                        ),
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

  Widget _buildLabel(String text) => Text(
    text, 
    style: const TextStyle(
      fontSize: 10, 
      fontWeight: FontWeight.bold, 
      color: Colors.grey
      )
    );
  
  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12, 
      vertical: 14
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), 
      borderSide: BorderSide(
        color: Colors.grey.shade300
      )
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), 
      borderSide: BorderSide(
        color: Colors.grey.shade300, 
        width: 2
      )
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), 
      borderSide: const BorderSide(
        color: AppTheme.primary, 
        width: 2
      )
    ),
    filled: true,
    fillColor: Colors.grey[50],
  );
}