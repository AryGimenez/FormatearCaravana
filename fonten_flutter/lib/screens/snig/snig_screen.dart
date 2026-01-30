// fonten_flutter/lib/screens/snig/snig_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'snig_handler.dart';
import 'caravana_item.dart';
import '../config_drawer/config_drawer_screen.dart';
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
    final handler = Provider.of<SnigHandler>(
        context); // Obtiene el handler usando Provider lo que permite acceder a los datos del handler desde cualquier lugar de la app.

    // Escucha errores y muestra Snackbar un menu inferior notificando al usuario
    // que a ocurrido un error.
    if (handler.errorMessage != null) { // Si hay un error
      WidgetsBinding.instance.addPostFrameCallback((_) { // Asegura que el snackbar se muestre despues de que el arbol de widgets se haya construido
        ScaffoldMessenger.of(context).showSnackBar(// Muestra el snackbar
          SnackBar( // Muestra el snackbar
            content: Text(handler.errorMessage!), // Muestra el mensaje de error
            backgroundColor: Colors.red, // Color del snackbar
            behavior: SnackBarBehavior
                .floating, // Muestra el snackbar como un menu inferior
          ),
        );
        handler.clearError(); // Limpia el error
      });
    }

    return Scaffold( // Muestra la pantalla
      // 1. EL MENÚ LATERAL
      drawer: const ConfigDrawer(),

      // 2. LA BARRA SUPERIOR
      appBar: AppBar(
        title: const Text("SNIG Connect",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

          // Cabecera con "Seleccionar Todo"
          if (!handler.isLoading && handler.caravanasFiltradas.isNotEmpty)
            _buildSelectAllHeader(handler),

          if (!handler.isLoading)
            Expanded(
              child: handler.caravanasFiltradas.isEmpty
                  ? const Center(
                      child: Text("Carga un archivo desde el menú lateral"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: handler.caravanasFiltradas.length,
                      itemBuilder: (context, index) {
                        return CaravanaItem(
                          caravana: handler.caravanasFiltradas[index],
                          onToggle: () => handler.toggleSeleccion(index),
                          onDelete: () => handler.eliminarCaravana(index),
                          onModify: () => handler.modificarCaravana(index),
                        );
                      },
                    ),
            ),

          // Botones eliminar Caravanas Seleccionadas (Solo aparecen si hay seleccionados)
          if (handler.totalCaravanasSeleccionadas > 0)
            _buildDeleteCaravanasButtons(handler),
        ],
      ),

      // 4. BOTÓN FLOTANTE - AGREGAR NUEVA CARAVANA <!> Tengo que arreglarlo y implementar el mentodo cuando termine la interfas
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
          _buildStat("Todos", "${handler.totalCaravanas}"),
          _buildStat("Estan en Simulador", "${handler.totalCaravanasOk}",
              color: Colors.green),
          _buildStat(
              "Faltan en Simulador", "${handler.totalCaravanasFaltantes}",
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

  Widget _buildDeleteCaravanasButtons(SnigHandler handler) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Expanded(
            //<!> Boton elminiar lo seleccionado arreglar
            child: ElevatedButton.icon(
              onPressed: () => handler.eliminarSeleccionadas(),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text("ELIMINAR (${handler.totalCaravanasSeleccionadas})",
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

  Widget _buildSelectAllHeader(SnigHandler handler) {
    // Ajustamos el padding para alinear con el contenido de las tarjetas
    // ListView padding (16) + Card padding (16) + Border (5) aprox = ~37
    // Pero visualmente 32-36 suele quedar bien.
    return Padding(
      padding:
          const EdgeInsets.only(left: 34.0, right: 32.0, top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          // Checkbox alineado con el de los items
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: handler.areAllSelected,
              onChanged: handler.toggleSelectAll,
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "SELECCIONAR TODO",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(
                right: 8.0), // Ajuste fino para la etiqueta ACCIÓN
            child: Text(
              "ACCIÓN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
