// fonten_flutter/lib/screens/carga_masiva/carga_masiva_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart'; // Tu tema
import '../snig/snig_handler.dart'; // El handler principal
import 'carga_masiva_handler.dart';
import 'widgets/temp_caravana_item.dart';


class CargaMasivaScreen extends StatelessWidget {
  const CargaMasivaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ChangeNotifierProvider para crear la instancia del handler local
    return ChangeNotifierProvider(
      create: (_) => CargaMasivaHandler(),
      child: const _CargaMasivaContent(),
    );
  }
}

class _CargaMasivaContent extends StatelessWidget {
  const _CargaMasivaContent();
  
  // <DM!> Dibuja el la interfas El arbol de wintgent 
  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<CargaMasivaHandler>(context); // <DM!> Logica de la pantalla Carga Masiva 
    final mainHandler = Provider.of<SnigHandler>(context, listen: false); // <DM!> Logica de la pantalla principal se uda para notificar los cambios 
    // <!> Creo que se usa para construir la aplicaicon pero no lo tengo claro  
    return Scaffold( 
      backgroundColor: Colors.grey[100], // Fondo claro tipo 'background-light'
      // <DM!> Menu superiro de la aplicacion
      appBar: AppBar( // <!> Aca tengo una dudoa etnido que aca esta el numero pero pense que deberia estar el boton de flecha 
        title: const Text("CARGA MASIVA"), // Texto del menu
        backgroundColor: AppTheme.primary, // Color fondo 
        foregroundColor: Colors.white, // Color texto
        elevation: 2, // Efecto de sombra
      ),
      body: Column(
        children: [
          // ---------------------------------------------
          // 1. ÁREA DE ENTRADA (WhatsApp + Manual)
          // ---------------------------------------------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // <DM!> Menu Desplegable para cargar texto 
                // Tipo Ejemplo: 051115346 - 051115344- 057068293- 046458193
                _buildWhatsappSection(handler, context), 

                // <DM!> Menu para edicion caravanas manual 
                // <> Texto Guia 
                // <> Texto Fecah lectura
                // <> Texto Hora lectura
                if (!handler.isWhatsappExpanded) ...[ // <!> Por lo que entiendo colapsa el menu si el menu de carga texto que despliegue 
                  const SizedBox(height: 16),
                  _buildManualForm(context, handler), // <DM!>Funcion que manda menu ediocion manual 
                ],
              ],
            ),
          ),

          // ---------------------------------------------
          // 2. ENCABEZADO DE COLA
          // ---------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("COLA TEMPORAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2
                    ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    "Total: ${handler.tempQueue.length}", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary
                      )
                  ),
                )
              ],
            ),
          ),

          // ---------------------------------------------
          // 3. LISTA DE ITEMS (Expanded)
          // ---------------------------------------------
          Expanded(
            child: handler.tempQueue.isEmpty 
              ? Center(child: Text("La cola está vacía", style: TextStyle(color: Colors.grey[400])))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: handler.tempQueue.length,
                  itemBuilder: (context, index) => TempCaravanaItem(
                    caravana: handler.tempQueue[index],
                    onDelete: () => handler.eliminarDeCola(index),
                  ),
                ),
          ),

          // ---------------------------------------------
          // 4. BOTÓN FINAL <DM!> Boton que carga todo la caravana que logre cargar de el texto la gui y la fecah la toma de los camp;os de carga manjal 
          // ---------------------------------------------
          Container( 
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12))
            ),
            child: SizedBox(          // <!> Por aca el logo dewsapareses y no se donde 
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: handler.tempQueue.isEmpty 
                  ? null 
                  : () => handler.confirmarTodo(context, mainHandler),
                icon: const Icon(Icons.cloud_upload), // Icono de la accion   
                label: const Text("CONFIRMAR Y CARGAR TODO"), // Texto de la accion 
                

              style: ButtonStyle(
                // 1. Color de fondo
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey[300]!; 
                  }
                  return AppTheme.primary;
                }),
                
                // 2. Color de Texto e ICONO <!> Creo que aca esta el problema de que el logo al cargar una cravana no se ve pero si el texto 
                foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey[500]!;
                  }
                  return Colors.white;
                }),

                // 3. Estilo de texto
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),













                
                
                
                
                
                
                // <!> Esto creo que esta para sacar 
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: AppTheme.primary, // Color de fondo 
                //   foregroundColor: Colors.white, // Color de texto 
                //   textStyle: const TextStyle( // Estilo de la fuente 
                //     fontWeight: FontWeight.bold, // Peso de la fuente 
                //     fontSize: 16 // Tamaño de la fuente 
                //     )
                // ),









              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS INTERNOS ---
  // <DM!> Retorna el menu desplegado de texto whatsapp 
  Widget _buildWhatsappSection(CargaMasivaHandler handler, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: handler.isWhatsappExpanded 
        ? Colors.green[50] // Color de fondo 
        : Colors.white, // Color de fondo 
        border: Border.all(
          color: handler.isWhatsappExpanded 
          ? Colors.green[200]! // Color de la linea 
          : Colors.grey[300]!), // Color de la linea 
        borderRadius: BorderRadius.circular(8), // Radio de la esquina 
      ),
      child: Column(
        children: [
          // Cabecera del Acordeón
          InkWell(
            onTap: handler.toggleWhatsapp,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.chat, 
                  color: Colors.green),
                  const SizedBox(width: 8),

                  Expanded(
                    child: handler.isWhatsappExpanded
                      // CASO A: EXPANDIDO (Usamos Columna para que entre todo)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
                          children: [
                            // 1. Título pequeño
                            Text("PEGAR DESDE WHATSAPP", 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Negrita
                                color: Colors.green, // Color verde
                                fontSize: 10 // Un poco más chico
                              )
                            ),
                            const SizedBox(height: 2),
                            
                            // 2. Datos en la línea de abajo
                            Row(
                              children: [
                                // GIA
                                Text(
                                  "GIA: ${handler.giaController.text.isEmpty 
                                  ? '---' // Si está vacío muestra '---'
                                  : handler.giaController.text
                                  }",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Negrita
                                    color: Colors.green[800], // Color verde
                                    fontSize: 13 // Tamaño de fuente
                                    ),
                                ),
                                
                                // Separador vertical
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  width: 1, 
                                  height: 12, 
                                  color: Colors.green
                                ),

                                // Fecha y Hora (Con Flexible para evitar errores si es muy largo)
                                Flexible(
                                  child: Text(
                                    "${handler.selectedDate.day}/${handler.selectedDate.month} - ${handler.selectedTime.format(context)}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800], fontSize: 13),
                                    overflow: TextOverflow.ellipsis, // Si es muy largo pone "..."
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      // CASO B: CONTRAÍDO (Solo título)
                      : Text("PEGAR DESDE WHATSAPP", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Negrita
                          color: Colors.green 
                        )
                      ),
                  ),
                  const Spacer(),
                  Icon(handler.isWhatsappExpanded 
                    ? Icons.expand_less // Si está expandido muestra el icono de menos
                    : Icons.expand_more, // Si está contraído muestra el icono de más
                  color: Colors.green),
                ],
              ),
            ),
          ),
          
          // Area de texto para pegar desde whatsapp
          if (handler.isWhatsappExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12, // Izquierda
                0, // Arriba
                12, // Derecha
                12 // Abajo
              ),
              child: Column(
                children: [
                  TextField( // Cuadro de texto 
                    controller: handler.whatsappController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Pegue aquí el texto (ej: Dicose 150... 0511...)",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Boton para cargar de le texto a las caravanas 
                  SizedBox( //<!> Nose lo que es SizedBox porque no uso un boton normal
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: handler.procesarTextoWhatsapp,
                      icon: const Icon(Icons.filter_alt),
                      label: const Text("LIMPIAR Y EXTRAER"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  /// Construye el formulario de ingreso manual de caravanas.
  /// Diseñado para ser operado con una sola mano y con alta visibilidad en condiciones de campo.
  Widget _buildManualForm(BuildContext context, CargaMasivaHandler handler) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Caravana ---  
        const Text( // <DM!> Texto ensima del campo editable 
          "CARAVANA", 
          style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.
            bold, color: Colors.grey)
            ),
        
        const SizedBox(height: 4),  

        TextField(//<DM!> Campo editable Caravana
          controller: handler.caravanaController, // Controller del campo editable
          keyboardType: TextInputType.number, // Determina el tipo de teclado numeros
          onChanged: (val) => handler.validarInputCaravana(val), // Valida el texto mientras se escribe 
          style: const TextStyle( // Determina el estilo del texto
            fontSize: 24, // Tamaño de la fuente
            fontWeight: FontWeight.bold, // Negrita
            letterSpacing: 1.5 // Espaciado entre letras
            ),
          decoration: InputDecoration(// Decoracion del campo editable
            hintText: "858...", // Texto que aparece cuando el campo esta vacio
            contentPadding: const EdgeInsets.symmetric( // Determina el espaciado interno del campo
              horizontal: 16, // Espaciado horizontal
              vertical: 16 // Espaciado vertical
              ),
            border: OutlineInputBorder( // Borde del campo
              borderRadius: BorderRadius.circular(8) // Radio del borde
              ),
            errorText: handler.caravanaErrorText, // Muestra el mensaje de error si existe
          ),
        ),
        
        const SizedBox(height: 12), // seaparado 
        
        // Fila GIA y HORA
        Row(
          children: [
            // GIA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("GIA / VID", 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey
                    )),
                  const SizedBox(height: 4),
                  TextField(
                    controller: handler.giaController,
                    decoration: const InputDecoration(
                      hintText: "A-123",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, 
                        vertical: 14
                        ),
                      border: OutlineInputBorder(),
                    ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("HORA", 
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey
                        )),
                      
                      // Switch Correlativa pequeño
                      // Row( // <!> Voy a sacarlo y dejar que simpre trabaje correlativo 
                      //   children: [
                      //     const Text("Correlativa", style: TextStyle(fontSize: 8)),
                      //     SizedBox(
                      //       height: 20,
                      //       child: Switch(
                      //         value: handler.isCorrelativeEnabled,
                      //         onChanged: handler.toggleCorrelative,
                      //         activeColor: AppTheme.primary,
                      //       ),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context, 
                        initialTime: handler.selectedTime);
                      if (time != null) handler.updateTime(time);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), 
                        borderRadius: BorderRadius.circular(4)
                        ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            handler.selectedTime.format(context), 
                            style: const TextStyle(fontSize: 16)
                            ),
                          Icon(
                            Icons.access_time,
                            size: 18
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Fecha y Botón Agregar
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("FECHA", 
                    style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey
                    )),
                  SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context, 
                        initialDate: handler.selectedDate,
                        firstDate: DateTime(2000), 
                        lastDate: DateTime(2100)
                      );
                      if (date != null) handler.updateDate(date);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${handler.selectedDate.day}/${handler.selectedDate.month}/${handler.selectedDate.year}", 
                            style: const TextStyle(fontSize: 16)
                            ),
                          Icon(Icons.calendar_today, size: 18)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: handler.agregarManual,
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.white
                    ),
                  label: Text("AGREGAR", 
                      style: TextStyle(color: Colors.white)
                    ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}