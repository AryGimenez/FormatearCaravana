// fonten_flutter/lib/screens/snig/snig_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'snig_handler.dart';
import 'caravana_item.dart';
import '../config_drawer/config_drawer.dart';
import '../../core/theme/app_theme.dart';

class SnigScreen extends StatefulWidget {
  const SnigScreen({super.key});

  @override
  State<SnigScreen> createState() => _SnigScreenState();
}

class _SnigScreenState extends State<SnigScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga inicial si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SnigHandler>(context, listen: false).fetchCaravanas();
    });
  }

  void _onSearch(String query) {
    Provider.of<SnigHandler>(context, listen: false).filterCaravanas(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<SnigHandler>(context);

    // Escuchar errores y mostrar Snackbar
    if (handler.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handler.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        handler.clearError();
      });
    }

    return Scaffold(
      // 1. EL MENÚ LATERAL
      drawer: const ConfigDrawer(),

      // 2. LA BARRA SUPERIOR
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SNIG Connect",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Lote #${handler.nroFormulario}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),

      // 3. EL CUERPO (LISTA)
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Buscar por EID o visual...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Resumen rápido de totales
          _buildSummaryBar(handler),

          if (handler.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          if (!handler.isLoading)
            Expanded(
              child: handler.caravanas.isEmpty
                  ? const Center(
                      child: Text("Carga un archivo desde el menú lateral"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: handler.caravanas.length,
                      itemBuilder: (context, index) {
                        return CaravanaItem(
                          caravana: handler.caravanas[index],
                          onToggle: () => handler.toggleSeleccion(index),
                          onDelete: () => handler.eliminarCaravana(index),
                        );
                      },
                    ),
            ),

          // Botones de Acción (Solo aparecen si hay seleccionados)
          if (handler.selectedCount > 0) _buildActionButtons(handler),
        ],
      ),

      // 4. BOTÓN FLOTANTE
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSummaryBar(SnigHandler handler) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("Evaluados", "${handler.totalEvaluados}"),
          _buildStat("Leídos", "${handler.totalOk}", color: Colors.green),
          _buildStat("Faltantes", "${handler.totalFaltantes}",
              color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons(SnigHandler handler) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => handler.eliminarSeleccionadas(),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text("ELIMINAR (${handler.selectedCount})",
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
