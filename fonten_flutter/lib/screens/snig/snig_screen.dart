// fonten_flutter/lib/screens/snig/snig_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'snig_handler.dart';
import 'caravana_item.dart';
import '../config_drawer/config_drawer_screen.dart';
import '../../core/theme/app_theme.dart';
import '../carga_masiva/carga_masiva_screen.dart';


//  <DM!> parte vidual 
  // de la pantalla de configuracion del Menu principal de la aplicacion 
  // Funcionalidades 
  // <> Barra de busqueda 
  // <> Barra de resumen de totales 
  // <> Barra de acciones 
  // <> Lista de Caravanas Caravanas_Item
  // <> Barra de navegacion inferior  
  // <>  Agregar caravana va al menu Cargar_Masiva Caravanas 
  // <>  Eliminar caravasn seleccionadas
  // <>  Boton Remover el simulador cargado
class SnigScreen extends StatefulWidget {
  const SnigScreen({super.key});

  @override
  State<SnigScreen> createState() => _SnigScreenState();
}

class _SnigScreenState extends State<SnigScreen> {
  final TextEditingController _searchController = TextEditingController(); // <!> Esto no se si va aca. 

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

  // <DM!>  Despliega el arblo de witget la estructura de la interfas la 
  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<SnigHandler>(
        context); // Obtiene el handler usando Provider lo que permite acceder a los datos del handler desde cualquier lugar de la app.

    // Escucha errores y muestra Snackbar un menu inferior notificando al usuario
    // que a ocurrido un error. <!> Esto no tengo vien claro para que es
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

    // Muestra la pantalla
    return Scaffold( 
      // 1. EL MENÚ LATERAL --------------------------------------------------
      drawer: const ConfigDrawer(),

      // 2. LA BARRA SUPERIOR ------------------------------------------------
      appBar: AppBar(
        title: const Text("SNIG Connect",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),

      // 3. EL CUERPO (LISTA) ------------------------------------------------
      body: Column( 
        children: [ 
          Padding(
            padding: const EdgeInsets.all(16.0), // Padding de la barra de búsqueda
            child: TextField( // TextField de la barra de búsqueda
              controller: _searchController,// Controlador de la barra de búsqueda
              onChanged: _onSearch,// Funcion que se ejecuta cuando se cambia el texto de la barra de búsqueda
              decoration: InputDecoration(
                hintText: 'Buscar  o visual...',
                prefixIcon: const Icon(Icons.search),
                
                // AGREGAR ESTO: El botón de filtro a la derecha
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_list, 
                    // Si hay filtros activos, lo pintamos de verde para avisar
                    color: (handler.filtroGia != null || handler.filtroFecha != null) 
                        ? AppTheme.primary 
                        : Colors.grey
                  ),
                  onPressed: () => _mostrarPanelFiltros(context, handler),
                ),
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              
            ),
          ),

          // <DM!> Resumen rápido de totales Total Caravanas / Total Caravanas / Caravanas En Simulador / Total Fuera Simulador
          _buildSummaryBar(handler),// Muestra la pantalla

          if (handler.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          // Cabecera con "Seleccionar Todo"
          if (!handler.isLoading && handler.caravanasFiltradas.isNotEmpty) // <DM!> Si hay caravanas cargadas
            _buildSelectAllHeader(handler),

          if (!handler.isLoading) // <DM!> Si no hay caravanas cargadas
            Expanded(
              child: handler.caravanasFiltradas.isEmpty
                  ? const Center(
                      child: Text("Carga un archivo desde el menú lateral"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: handler.caravanasFiltradas.length,
                      itemBuilder: (context, index) {
                        return CaravanaItem(
                          caravana: handler.caravanasFiltradas[index], // Caravana a mostrar
                          onToggle: () => handler.toggleSeleccion(index), // Funcion que se ejecuta cuando se cambia el estado de la caravana
                          onDelete: () => handler.eliminarCaravana(index), // Funcion que se ejecuta cuando se elimina la caravana
                          onModify: () => handler.modificarCaravana(index), // Funcion que se ejecuta cuando se modifica la caravana
                        );
                      },
                    ),
            ),
        ],
      ),

      // Barra de acciones
      bottomNavigationBar: _buildTripleActionBar(handler), // Barra de acciones
    );
  }




  /// Despliega un panel modal inferior (BottomSheet) con opciones de filtrado avanzado.
  ///
  /// A diferencia de los métodos `_build...` que retornan un Widget para ser incrustado,
  /// este método ejecuta la función [showModalBottomSheet] del sistema, superponiendo
  /// una nueva capa interactiva sobre la pantalla actual.
  ///
  /// Funcionalidades del panel:
  /// 1. Selección de **Guía (GIA)** mediante un Dropdown dinámico.
  /// 2. Selección de **Fecha** mediante un calendario.
  /// 3. Botón para **limpiar** todos los filtros activos.
  ///
  /// Utiliza un [Consumer] interno para redibujar solo el contenido del panel
  /// cuando el usuario cambia una opción, sin reconstruir toda la pantalla de fondo.
  void _mostrarPanelFiltros(BuildContext context, SnigHandler handler) {
    showModalBottomSheet( // Muestra un menu inferior para filtrar las caravanas
      context: context, // Contexto de la pantalla
      shape: const RoundedRectangleBorder( // Forma del menu inferior
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Bordes redondeados
      ),
      builder: (context) { // Construye el menu inferior
        // Usamos Consumer para que el panel se redibuje si cambiamos algo
        return Consumer<SnigHandler>( // Consumer para que el panel se redibuje si cambiamos algo
          builder: (context, handler, _) { // Construye el menu inferior
            return Padding( // Padding del menu inferior
              padding: const EdgeInsets.all(20.0), // Padding del menu inferior
              child: Column( // Columna del menu inferior
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                crossAxisAlignment: CrossAxisAlignment.start, // Alineacion al inicio
                children: [ // Lista de widgets
                  // Título y Botón de Limpiar
                  Row( // Fila del titulo y boton de limpiar
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alineacion al centro
                    children: [ // Lista de widgets
                      const Text("Filtros Avanzados", // Titulo
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: 
                          FontWeight.bold
                          )), // Estilo del titulo
                      TextButton(
                        onPressed: () => handler.limpiarFiltrosAvanzados(), // Funcion que se ejecuta cuando se limpia el filtro
                        child: const Text("Limpiar todo", 
                          style: TextStyle(color: Colors.red)), // Texto del boton
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 1. DROPDOWN DE GUÍA (GIA)
                  const Text("Filtrar por Guía:", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey
                    )),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Seleccionar Guía"),
                        value: handler.filtroGia,
                        items: handler.listaGiasDisponibles.map((String gia) {
                          return DropdownMenuItem<String>(
                            value: gia,
                            child: Text(gia),
                          );
                        }).toList(),
                        onChanged: (val) => handler.setFiltroGia(val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. SELECTOR DE FECHA
                  const Text("Filtrar por Fecha:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: handler.filtroFecha ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) handler.setFiltroFecha(picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            handler.filtroFecha == null 
                              ? "Todas las fechas" 
                              : "${handler.filtroFecha!.day}/${handler.filtroFecha!.month}/${handler.filtroFecha!.year}",
                            style: TextStyle(
                              color: handler.filtroFecha == null ? Colors.grey[600] : Colors.black
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }



  // <DM!> Por lo que me acuerdo estao es para mostrar un resumen de las caravanas filtradas
  // 
  Widget _buildSummaryBar(SnigHandler handler) {  
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat( // Boton Muestra todo los totales de caravanas
            label: "Todos", // Texto del boton
            value: "${handler.totalCaravanas}", // Valor del boton
            type: CaravanaFilterType.todos, // Tipo de filtro
            handler: handler, // Manejador de eventos
          ),
          _buildStat( // Boton filtra las caravanas que estan en simulador
            label: "En Simulador", // Texto del boton
            value: "${handler.totalCaravanasOk}", // Valor del boton
            color: Colors.green, // Color del boton
            type: CaravanaFilterType.ok, // Tipo de filtro
            handler: handler, // Manejador de eventos
          ),
          _buildStat( // Boton filtra las caravanas que no estan en simulador
            label: "Faltantes", // Texto del boton
            value: "${handler.totalCaravanasFaltantes}", // Valor del boton
            color: Colors.red, // Color del boton
            type: CaravanaFilterType.faltantes, // Tipo de filtro
            handler: handler, // Manejador de eventos
          ),
        ],
      ),
    );
  }

  // <!> no me acuerod documetalo 
  Widget _buildStat({
    required String label, // Texto del boton
    required String value, // Valor del boton
    required CaravanaFilterType type, // Tipo de filtro
    required SnigHandler handler, // Manejador de eventos
    Color color = Colors.black // Color del texto
  }) {
    final bool isSelected = handler.activeFilter == type;

    
    return InkWell(
      onTap: () => handler.setFilter(type), // Funcion que se ejecuta cuando se cambia el estado de la caravana
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Resaltamos el filtro activo con un fondo suave
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, // Peso del texto
              color: color // Color del texto
            )),
            Text(label, style: TextStyle(
              fontSize: 10, 
              color: isSelected ? color : Colors.grey, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )),
          ],
        ),
      ),
    );
  }

  // Widget _buildSummaryBar(SnigHandler handler) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildStat("Todos", "${handler.totalCaravanas}"),
  //         _buildStat("Estan en Simulador", "${handler.totalCaravanasOk}",
  //             color: Colors.green),
  //         _buildStat(
  //             "Faltan en Simulador", "${handler.totalCaravanasFaltantes}",
  //             color: Colors.red),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStat(String label, String value, {Color color = Colors.black}) {
  //   return Column(
  //     children: [
  //       Text(value,
  //           style: TextStyle(
  //               fontSize: 18, fontWeight: FontWeight.bold, color: color)),
  //       Text(label,
  //           style: const TextStyle(
  //               fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
  //     ],
  //   );
  // }

  // <!> no me acuerod documetalo 
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
                // IZQUIERDA: ELIMINAR  -----
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

                // MEDIO: Eliminar SIMULAR  ----- 
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

                // DERECHA: AGREGAR  ----- 
                _buildBottomButton(
                  label: "AGREGAR",
                  icon: Icons.add_circle_outline,
                  color: Colors.green[700]!,
                  // <!> Carga el menu de carga masiva No entiedo bien la estructrua que hace para la parte de notificacion de cambio de estado
                  onTap: () async { // 1. Hacemos la función async

                    
                    await Navigator.push( // Detiene la ejecución aquí (await) hasta que la pantalla nueva se cierre (pop).
                      context, // Necesario para saber dónde estamos en el árbol de widgets.
                      MaterialPageRoute( // Crea la animación estándar de transición de pantalla (deslizamiento).
                        builder: (context) => ChangeNotifierProvider.value( // Inyecta un Provider existente en la nueva ruta.
                          // 1. EL SECRETO: En lugar de 'create', usamos 'value'.
                          // Le pasamos la instancia VIVA del SnigHandler que ya tiene los datos.
                          // 'listen: false' es vital: este botón solo NECESITA el objeto, no necesita redibujarse si cambia.
                          value: Provider.of<SnigHandler>(context, listen: false),
                          
                          // 2. LA PANTALLA HIJA:
                          // Ahora CargaMasivaScreen podrá hacer Provider.of<SnigHandler> y recibirá
                          // la misma instancia exacta que tiene la pantalla padre.
                          child: const CargaMasivaScreen(),
                        ),
                      ),
                    );

                    // 3. Cuando volvemos, forzamos la actualización de la UI
                    // Esto le dice al Handler: "Che, revisá el ApiService que seguro cambiaron datos"
                    if (context.mounted) {
                      Provider.of<SnigHandler>(context, listen: false).refrescarDesdeService();
                    }                  
                  },
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

  // Widget auxiliar para los botones de la barra <!> Mejora el comentario
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
