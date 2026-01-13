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
                // Campo Número de Formulario
                const Text("NÚMERO DE FORMULARIO *",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                // Campo Gia a asignar -------- 
                TextField(
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

                const SizedBox(height: 25),

                // Botones de Carga (CSV / PDF)
                _buildActionButton(
                  label: "CARGAR CSV",
                  sub: "Importar lista de animales",
                  icon: Icons.table_view,
                  onTap: () => handler.cargarArchivoCsv(),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: "CARGAR PDF",
                  sub: "Del Simulador",
                  icon: Icons.picture_as_pdf,
                  onTap: () {},
                ),

                const SizedBox(height: 25),
                const Divider(),

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

  Widget _buildActionButton(
      {required String label,
      required String sub,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(sub,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            Icon(icon, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
