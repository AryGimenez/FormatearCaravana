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

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<CargaMasivaHandler>(context);
    final mainHandler = Provider.of<SnigHandler>(context, listen: false);
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
                _buildWhatsappSection(handler),

                // <DM!> Formulario Manual (Se oculta si WhatsApp está expandido)
                if (!handler.isWhatsappExpanded) ...[
                  const SizedBox(height: 16),
                  _buildManualForm(context, handler),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    "Total: ${handler.tempQueue.length}", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)
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
          // 4. BOTÓN FINAL (Footer)
          // ---------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12))
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: handler.tempQueue.isEmpty 
                  ? null 
                  : () => handler.confirmarTodo(context, mainHandler),
                icon: const Icon(Icons.cloud_upload),
                label: const Text("CONFIRMAR Y CARGAR TODO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS INTERNOS ---

  Widget _buildWhatsappSection(CargaMasivaHandler handler) {
    return Container(
      decoration: BoxDecoration(
        color: handler.isWhatsappExpanded ? Colors.green[50] : Colors.white,
        border: Border.all(color: handler.isWhatsappExpanded ? Colors.green[200]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
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
                  const Icon(Icons.chat, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text("PEGAR DESDE WHATSAPP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Spacer(),
                  Icon(handler.isWhatsappExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.green),
                ],
              ),
            ),
          ),
          
          // Contenido Expandible
          if (handler.isWhatsappExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  TextField(
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
                  SizedBox(
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

  Widget _buildManualForm(BuildContext context, CargaMasivaHandler handler) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Caravana Grande
        const Text("CARAVANA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: handler.eidController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          decoration: InputDecoration(
            hintText: "858...",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Fila GIA y HORA
        Row(
          children: [
            // GIA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("GIA / VID", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: handler.giaController,
                    decoration: const InputDecoration(
                      hintText: "A-123",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // HORA y Switch
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("HORA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      // Switch Correlativa pequeño
                      Row(
                        children: [
                          const Text("Correlativa", style: TextStyle(fontSize: 8)),
                          SizedBox(
                            height: 20,
                            child: Switch(
                              value: handler.isCorrelativeEnabled,
                              onChanged: handler.toggleCorrelative,
                              activeColor: AppTheme.primary,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: handler.selectedTime);
                      if (time != null) handler.updateTime(time);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(handler.selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.access_time, size: 18)
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
                  const Text("FECHA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
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
                          Text("${handler.selectedDate.day}/${handler.selectedDate.month}/${handler.selectedDate.year}", style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.calendar_today, size: 18)
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
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text("AGREGAR", style: TextStyle(color: Colors.white)),
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