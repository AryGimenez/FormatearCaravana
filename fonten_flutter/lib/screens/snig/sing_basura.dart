import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Librería para formateo de fechas y horas
import '../../models/caravana_models.dart';
import '../../core/theme/app_theme.dart';

class CaravanaItem extends StatelessWidget {
  // Definición de las propiedades necesarias para el componente
  final CaravanaModel caravana; // El modelo de datos de la vaca/animal
  final VoidCallback onToggle;  // Acción para el checkbox de selección
  final VoidCallback onDelete;  // Acción para eliminar el registro
  final VoidCallback onModify;  // Acción para editar (el lápiz de Figma)

  const CaravanaItem({
    super.key,
    required this.caravana,
    required this.onToggle,
    required this.onDelete,
    required this.onModify,
  });

  /// Construye la interfaz visual de la tarjeta de la caravana.
  /// 
  /// Este método describe la jerarquía de widgets que componen el ítem:
  /// 1. Un [Container] con borde lateral dinámico según el estado.
  /// 2. Un [Row] principal que organiza el selector, la información y las acciones.
  /// 3. Una [Column] central expandida para los datos de trazabilidad (GIA, ID, Fecha).
  /// 4. Un [Column] de acciones laterales para estado y eliminación.
  /// 
  /// Retorna un [Widget] que responde visualmente a las propiedades del modelo [caravana].
  @override
  Widget build(BuildContext context) {
    // Transforma la fecha del modelo en un String legible (Ej: 24-10-2023)
    String fechaFormateada = DateFormat('dd-MM-yyyy').format(caravana.hf_lectura);
    
    // Transforma la hora del modelo. Nota: 'HH:mm' quitaría los segundos como en Figma
    String horaFormateada = DateFormat('HH:mm:ss').format(caravana.hf_lectura);

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Espacio entre tarjetas
      decoration: BoxDecoration(
        color: AppTheme.surface, // Color de fondo del tema
        borderRadius: BorderRadius.circular(12), // Bordes redondeados de la tarjeta
        border: Border(
          // Crea la línea lateral de color dinámica según el estado OK/Faltante
          left: BorderSide(
              color: caravana.esOk ? Colors.green : Colors.red, 
              width: 5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Margen interno de la tarjeta
        child: Row(
          children: [
            // Control de selección de la caravana
            Checkbox(
              value: caravana.seleccionada,
              onChanged: (_) => onToggle(), // Llama al callback de selección
              activeColor: AppTheme.primary,
            ),
            const SizedBox(width: 8), // Separación entre checkbox y texto
            Expanded(
              // Columna central que ocupa todo el espacio disponible
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea texto a la izquierda
                children: [
                  Row(
                    children: [
                      _buildChip("GIA: ${caravana.gia}"), // Etiqueta del lote/GIA
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(horaFormateada,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Número de caravana resaltado en monoespaciado para lectura técnica
                  Text(caravana.caravana,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace')),
                  // Fecha de la lectura debajo del número
                  Text(fechaFormateada,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // Columna derecha para el estado y el botón de borrar
            Column(
              children: [
                _buildStatusBadge(caravana.esOk), // Badge de OK o FALTANTE
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete, // Ejecuta la función de borrado
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para crear etiquetas pequeñas (Chips)
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // Widget auxiliar para el Badge de estado con colores dinámicos
  Widget _buildStatusBadge(bool isOk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOk ? AppTheme.okBg : AppTheme.errorBg, // Color de fondo según estado
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOk ? "OK" : "FALTANTE",
        style: TextStyle(
            color: isOk ? AppTheme.okText : AppTheme.errorText, // Color de texto según estado
            fontSize: 9,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}








import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'snig_handler.dart';
import 'caravana_item.dart';
import '../config_drawer/config_drawer.dart';
import '../../core/theme/app_theme.dart';



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



class SnigScreen extends StatefulWidget {
  const SnigScreen({super.key});

  @override
  _SnigScreenState createState() => _SnigScreenState();
}

class _SnigScreenState extends State<SnigScreen> {
  late Future<void> _caravanasFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final handler = Provider.of<SnigHandler>(context, listen: false);
    _caravanasFuture = handler.fetchCaravanas();
  }

  void _onSearch(String query) {
    final handler = Provider.of<SnigHandler>(context, listen: false);
    handler.filterCaravanas(query);
  }

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<SnigHandler>(context);

    return Scaffold(
      drawer: const ConfigDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SNIG Connect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Lote #${handler.nroFormulario}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda (Estilo ClientsScreen)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                labelText: 'Buscar por EID o Visual',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          _buildSummaryBar(handler),

          Expanded(
            child: FutureBuilder(
              future: _caravanasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (handler.filteredCaravanas.isEmpty) {
                  return const Center(child: Text("No se encontraron caravanas"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: handler.filteredCaravanas.length,
                  itemBuilder: (context, index) {
                    final caravana = handler.filteredCaravanas[index];
                    return CaravanaItem(
                      caravana: caravana,
                      isSelected: handler.isSelected(caravana.eid),
                      onToggle: (val) => handler.toggleSelection(caravana.eid, val ?? false),
                    );
                  },
                );
              },
            ),
          ),
          
          // Botones de Acción (Solo aparecen si hay seleccionados)
          if (handler.selectedCount > 0)
            _buildActionButtons(handler),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {}, 
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryBar(SnigHandler handler) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("Evaluados", "${handler.totalEvaluados}"),
          _buildStat("OK", "${handler.totalOk}", color: Colors.green),
          _buildStat("Faltantes", "${handler.totalFaltantes}", color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons(SnigHandler handler) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => handler.eliminarSeleccionadas(),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text("ELIMINAR (${handler.selectedCount})", style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/caravana_models.dart';
import '../../services/csv_service.dart';

class SnigHandler with ChangeNotifier {
  final CsvService _csvService = CsvService();
  
  List<Caravana> _caravanas = [];           // Lista original
  List<Caravana> _filteredCaravanas = [];  // Lista para la UI
  final Map<String, bool> _selectedCaravanas = {}; // Mapa EID -> bool
  
  String _nroFormulario = "2680416";
  bool _isLoading = false;

  // Getters
  List<Caravana> get filteredCaravanas => _filteredCaravanas;
  String get nroFormulario => _nroFormulario;
  bool get isLoading => _isLoading;
  int get selectedCount => _selectedCaravanas.values.where((v) => v).length;

  // Totales basados en la lista filtrada (para que el resumen cambie al buscar)
  int get totalEvaluados => _filteredCaravanas.length;
  int get totalOk => _filteredCaravanas.where((c) => c.esOk).length;
  int get totalFaltantes => _filteredCaravanas.where((c) => !c.esOk).length;

  void setNroFormulario(String value) {
    _nroFormulario = value;
    notifyListeners();
  }

  // Simula el fetchClients()
  Future<void> fetchCaravanas() async {
    _isLoading = true;
    // notifyListeners(); // No es necesario si usas FutureBuilder
    
    // Aquí podrías cargar de una DB local en el futuro
    _filteredCaravanas = List.from(_caravanas);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarArchivoCsv() async {
    try {
      final nuevas = await _csvService.pickAndParseCsv();
      if (nuevas != null) {
        _caravanas = nuevas;
        _filteredCaravanas = List.from(_caravanas);
        _selectedCaravanas.clear(); // Limpiar selecciones al cargar nuevo archivo
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al cargar CSV: $e");
      rethrow;
    }
  }

  // Lógica de filtrado idéntica a la de Clientes
  void filterCaravanas(String query) {
    if (query.isEmpty) {
      _filteredCaravanas = List.from(_caravanas);
    } else {
      _filteredCaravanas = _caravanas.where((c) {
        return c.eid.contains(query) || c.vid.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // Manejo de selección (Igual a toggleRowSelection en Clientes)
  void toggleSelection(String eid, bool value) {
    _selectedCaravanas[eid] = value;
    notifyListeners();
  }

  bool isSelected(String eid) => _selectedCaravanas[eid] ?? false;

  void eliminarSeleccionadas() {
    _caravanas.removeWhere((c) => _selectedCaravanas[c.eid] == true);
    _selectedCaravanas.clear();
    filterCaravanas(""); // Resetear vista
    notifyListeners();
  }
}