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
                const SizedBox(height: 25),

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

                const SizedBox(height: 25),
                const Divider(),





              // <!> De aca para bajo me gustaria separar estas opciones con un cadro o algo no se com que se sepa que esto es para modificar los camos de las caravanas seleccinadas
                // Gia de la lectura Cartel ---
                const Text(
                    "Gia de la lectura *", // <!> Esto no va tengo qeu cambiar el texto
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),

                const SizedBox(height: 8),

                // const SizedBox(height: 25), //
                // const Divider(),

                // Gia a asignar --------
                TextField(
                  //<!> Cambiar de color mas claro
                  onChanged: (val) => handler.setGia(val),
                  decoration: InputDecoration(
                    hintText: "Ej: C204416",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon:
                        const Icon(Icons.description, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                // Sección de Hora Masiva
                const Row(
                  children: [
                    Icon(Icons.schedule, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text("Hora Masiva",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Aquí irían los controles de selector de hora que dibujaste...


              ],
            ),
          ),

          // Botón Aplicar Cambios
          _buildApplyButton(context),
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
