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
  late Future<void> _caravansFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final handler = Provider.of<SnigHandler>(context, listen: false);
    _caravansFuture = handler.+++++++fetchCaravanas();
  }

  void _onSearch(String query) {
    Provider.of<SnigHandler>(context, listen: false).filterCaravanas(query);
  }

  Future<void> cargarDatos() async {
    await Provider.of<SnigHandler>(context, listen: false).cargarDatosEjemplo();
  }

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<SnigHandler>(context);

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
                hintText: 'Buscar por EID o Visual',
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

          Expanded(
            child: handler.filteredCaravanas.isEmpty
                ? Center(
                    child: Text(handler.caravanas.isEmpty
                        ? "Carga un archivo desde el menú lateral"
                        : "No se encontraron resultados"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: handler.filteredCaravanas.length,
                    itemBuilder: (context, index) {
                      return CaravanaItem(
                        caravana: handler.filteredCaravanas[index],
                        onToggle: () => handler.toggleSeleccion(index),
                        onDelete: () => handler.eliminarCaravana(index),
                      );
                    },
                  ),
          ),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
