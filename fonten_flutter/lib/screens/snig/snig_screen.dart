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

          // // Botones eliminar Caravanas Seleccionadas (Solo aparecen si hay seleccionados)
          // if (handler.totalCaravanasSeleccionadas > 0)
          //   _buildDeleteCaravanasButtons(handler),
        ],
      ),

      // // 4. BOTÓN FLOTANTE - AGREGAR NUEVA CARAVANA <!> Tengo que arreglarlo y implementar el mentodo cuando termine la interfas
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppTheme.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      //   onPressed: () {},
      // ),

      // Barra de acciones
      bottomNavigationBar: _buildTripleActionBar(handler),
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


  Widget _buildSelectAllHeader(SnigHandler handler) {
    // Ajustamos el padding para alinear con el contenido de las tarjetas
    // ListView padding (16) + Card padding (16) + Border (5) aprox = ~37
    // Pero visualmente 32-36 suele quedar bien.
    return Padding(
      padding:
          const EdgeInsets.only(
            left: 34.0, 
            right: 32.0, 
            top: 8.0, 
            bottom: 4.0),
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

  /// Construye la barra de acciones principal ubicada en la parte inferior de la pantalla.
  ///
  /// Esta barra centraliza las tres operaciones críticas del flujo de trabajo en el tubo:
  /// 1. **Eliminar**: Acción destructiva para remover caravanas seleccionadas (contextual).
  /// 2. **Simular**: Acción de comparación contra archivos externos (PDF/TXT).
  /// 3. **Agregar**: Acción manual para registrar nuevos animales.
  ///
  /// El diseño es colapsable mediante [handler.showBottomActions], permitiendo al 
  /// operario maximizar el área de visualización de la lista cuando sea necesario.  
  Widget _buildTripleActionBar(SnigHandler handler) {
    // 1. Obtenemos cuánto mide la barra del sistema (en Web es 0, en móvil varía)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;  

    // 2. Calculamos las alturas sumando ese padding
    final double expandedHeight = 93 + bottomPadding; 
    final double collapsedHeight = 40 + bottomPadding;    

    return AnimatedContainer( 
      duration: const Duration(milliseconds: 300), // Tiempo de la transición (suave para el usuario)
      height: handler.showBottomActions ? 
        expandedHeight : // Si es true, la algura menu desplegado
        collapsedHeight, // Si es false, menu colapsado
      curve: Curves.easeInOut, // Curva de animación <!> Esto no lo entiendo
      decoration: BoxDecoration( 
        color: Colors.white, // Fondo blanco para contraste con la lista
        boxShadow: [ // Sombra sutil para dar efecto de elevación 
          BoxShadow( 
            color: Colors.black12, // Sombra sutil para dar efecto de elevación 
            blurRadius: 10, // Desenfoque de la sombra
            offset: Offset(0, -2) // Desplazamiento de la sombra
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Bordes redondeados
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            // 1. TIRADOR / BOTÓN PARA COLAPSAR
          GestureDetector( 
            onTap: () => handler.toggleBottomActions(), // Cambia el estado de visibilidad
            child: Container(
              width: double.infinity, // Ancho completo
              color: Colors.transparent, // Para que sea fácil de tocar
              child: Icon(
                handler.showBottomActions ? 
                  Icons.keyboard_arrow_down : // Flecha hacia abajo si está expandido
                  Icons.keyboard_arrow_up, // Flecha hacia arriba si está colapsado
                color: Colors.grey, // Color gris para el icono
              ),
            ),
          ),

        // 2. LOS 3 BOTONES (Solo visibles si está expandido)
        if (handler.showBottomActions)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, // Padding izquierdo
              0, // Padding superior
              16, // Padding derecho
              5 // Padding inferior
              ), 
            child: Row(
              children: [
                // IZQUIERDA: ELIMINAR
                _buildBottomButton(
                  label: "BORRAR (${handler.totalCaravanasSeleccionadas})",
                  icon: Icons.delete_outline,
                  color: handler.totalCaravanasSeleccionadas > 0 ?
                   Colors.red : 
                   Colors.grey[300]!,
                  onTap: handler.totalCaravanasSeleccionadas > 0 
                      ? () => handler.eliminarSeleccionadas() 
                      : null,
                ),
                const SizedBox(width: 8),

                // MEDIO: SIMULAR
                _buildBottomButton(
                  label: "BORRAR SIMULAR",
                  icon: Icons.picture_as_pdf,
                  color: handler.isLoadingSimulador ? 
                    AppTheme.secondary : 
                    Colors.grey[300]!,
                  onTap: handler.isLoadingSimulador ? 
                    () => handler.descargarSimulador()
                    : null,
                ),
                const SizedBox(width: 8),

                // DERECHA: AGREGAR
                _buildBottomButton(
                  label: "AGREGAR",
                  icon: Icons.add_circle_outline,
                  color: Colors.green[700]!,
                  onTap: null
                ),
              ],
            ),
          ),
      ],
    ),
  );
}


// Widget auxiliar para los botones de la barra
Widget _buildBottomButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback? onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 12, 
                fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}




}
