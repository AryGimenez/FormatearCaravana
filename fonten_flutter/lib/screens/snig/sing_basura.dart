import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'snig_handler.dart';
import 'caravana_item.dart';
import '../config_drawer/config_drawer.dart';
import '../../core/theme/app_theme.dart';

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