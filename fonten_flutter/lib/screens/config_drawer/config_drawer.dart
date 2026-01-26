// fonten_flutter\lib\screens\config_drawer\config_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../snig/snig_handler.dart';
import '../../core/theme/app_theme.dart';

class ConfigDrawer extends StatelessWidget {
  const ConfigDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<SnigHandler>(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: AppTheme.background,
      child: Column(
        children: [
          // Cabecera del Drawer
          Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text("Configuración\nde Carga",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style:
                      IconButton.styleFrom(backgroundColor: Colors.grey[200]),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),

                //Botones de Importar y Exportar ----
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                  children: [
                    // Boton de Carga (CSV) ----
                    _buildActionButton(
                      label: "CARGAR CSV",
                      icon: Icons.table_view,
                      onTap: () => handler.cargarArchivoCsv(),
                    ),
                    const SizedBox(height: 8),

                    // Boton de Carga (PDF) ----
                    _buildActionButton(
                      label: "CARGAR PDF",
                      icon: Icons.picture_as_pdf,
                      onTap: () => handler.cargarArchivoPdf(),
                    ),

                    // Boton de Carga (TXT) ----
                    const SizedBox(height: 8),
                    _buildActionButton(
                      label: "IMPORTAR TXT",
                      icon: Icons.note_add,
                      onTap: () => handler.cargarArchivoTxt(),
                    ),

                    // Boton de Exportar (TXT) ----
                    const SizedBox(height: 8),
                    _buildActionButton(
                      label: "EXPORTAR TXT",
                      icon: Icons.download,
                      onTap: handler.totalCaravanasSeleccionadas > 0
                          ? () => handler.exportarArchivoTxt()
                          : null,
                      color: handler.totalCaravanasSeleccionadas > 0
                          ? null
                          : Colors.grey,
                    ),                    
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(),

                // Edicion masiva ----
                Container( // Contenedor de la sección de edición masiva
                  margin: const EdgeInsets.symmetric(vertical: 10), // Margen vertical
                  padding: const EdgeInsets.all(16), // Padding interno
                  decoration: BoxDecoration( // Decoración del contenedor
                    color: Colors.white, // Fondo blanco para resaltar sobre el fondo del drawer
                    borderRadius: BorderRadius.circular(15), // Radio de la esquina
                    border: Border.all(color: Colors.grey.shade300), // Borde del contenedor
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text( // TITULO DE LA SECCIÓN <!> Capas lo saco o mejoro la estetica no me gusta 
                        "MODIFICAR DATOS DE LA SELECCION",
                        style: TextStyle( 
                            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      
                      const SizedBox(height: 15), // Separador 
                      

                      // --- FILA GIA (Label + Switch) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Lbl Cambiar GIA
                          const Text("Cambiar GIA",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          
                          // Switch Cambiar GIA
                          Switch(
                            // Usamos el thumbIcon que te gustó
                            thumbIcon: WidgetStateProperty.fromMap(
                              <WidgetStatesConstraint, Icon>{
                                WidgetState.selected: const Icon(Icons.check, color: Colors.white),
                                WidgetState.any: const Icon(Icons.close, color: Colors.white),
                              },
                            ),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            value: handler.isGiaEditEnabled, // Debes crear esta bool en tu handler
                            onChanged: (val) => handler.setGiaEditEnabled(val),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      TextField(
                        enabled: handler.isGiaEditEnabled, // <--- ESTO LO BLOQUEA
                        onChanged: (val) => handler.setGia(val),
                        decoration: InputDecoration(
                          hintText: "Nuevo GIA (Ej: C204416)",
                          filled: true,
                          fillColor: handler.isGiaEditEnabled ? Colors.white : Colors.grey[100],
                          prefixIcon: Icon(Icons.description, 
                            color: handler.isGiaEditEnabled ? Colors.green : Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: handler.isGiaEditEnabled ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),


                // Aquí irían los controles de selector de hora que dibujaste...

                ),
              ],
            ),
          ),

          // Botón Aplicar Cambios
          _buildApplyButton(context),
        ],
      ),
    );
  }


  Widget _buildGiaEditSection(SnigHandler handler) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // --- FILA GIA (Label + Switch) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cambiar GIA",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                thumbIcon: WidgetStateProperty.fromMap(
                  <WidgetStatesConstraint, Icon>{
                    WidgetState.selected: const Icon(Icons.check, color: Colors.white),
                    WidgetState.any: const Icon(Icons.close, color: Colors.white),
                  },
                ),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                value: handler.isGiaEditEnabled,
                onChanged: (val) => handler.setGiaEditEnabled(val),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          // --- FILA NUEVO GIA (TextField) ---
          TextField(
            enabled: handler.isGiaEditEnabled,
            onChanged: (val) => handler.setGia(val),
            decoration: InputDecoration(
              hintText: "Nuevo GIA (Ej: C204416)",
              filled: true,
              fillColor: handler.isGiaEditEnabled ? Colors.white : Colors.grey[100],
              prefixIcon: Icon(Icons.description, 
                color: handler.isGiaEditEnabled ? Colors.green : Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: handler.isGiaEditEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildApplyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF121714),
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("APLICAR CAMBIOS",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  //<!> Esto tengo que cambiarlo para que el formato de los botones se mas pequiene ocupa mucho espacio

  Widget _buildActionButton(
      {required String label,
      required IconData icon,
      required VoidCallback? onTap,
      Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
