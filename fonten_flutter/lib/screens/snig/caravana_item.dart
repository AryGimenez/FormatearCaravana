import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/caravana_models.dart';
import '../../core/theme/app_theme.dart';


/// [CaravanaItem] es un componente visual que representa una tarjeta de identificación 
/// de ganado (Caravana) dentro de una lista.
///
/// Esta clase implementa el diseño, lo que incluye :
/// * Un indicador lateral de estado  
///   Verde 'OK' (La lectura coinside con el simulador), 
///   Rojo 'Faltante' (La lectura coinside con el simulador).
/// * Gestión de selección mediante un [Checkbox].
/// * Visualización de metadatos como el número de GIA, fecha y hora de lectura.
/// * Acciones de borrado mediante un callback [onDelete].
/// * Acciones de Modificar mediante un callback [onModify].
///
/// Utiliza [CaravanaModel] para la provisión de datos y depende del [AppTheme] 
/// para mantener la consistencia visual de la aplicación.
class CaravanaItem extends StatelessWidget {
  final CaravanaModel caravana;
  final VoidCallback onToggle; // Cambia el estado de seleccionada
  final VoidCallback onDelete; // Elimina la caravana
  final VoidCallback onModify; // Modifica la caravana


  /// Constructor de [CaravanaItem].
  /// 
  /// Requiere los siguientes parámetros para su funcionamiento:
  /// * [caravana]: El modelo de datos con la información del animal (EID, GIA, fecha).
  /// * [onToggle]: Callback que se dispara al marcar/desmarcar el checkbox de selección.
  /// * [onDelete]: Función para eliminar este registro de la lista de lecturas.
  /// * [onModify]: Callback para abrir la edición manual de datos (como la hora
  const CaravanaItem(
      {super.key,
      required this.caravana,
      required this.onToggle,
      required this.onDelete,
      required this.onModify});


  /// Construye la interfaz visual de la tarjeta de la caravana. <!> Reorganizar cuando cambie la estructura 
  /// 
  /// Este método describe la jerarquía de widgets que componen el ítem:
  /// 1. Un [Container] con borde lateral dinámico según el estado.
  /// 2. Un [Row] principal que organiza el selector, la información y las acciones.
  /// 3. Una [Column] central expandida para los datos de trazabilidad (GIA, ID, Fecha).
  /// 4. Un [Column] de acciones laterales para estado y eliminación. <!> Esto va a cambair cuando cambie la estructura
  /// 
  /// Retorna un [Widget] que responde visualmente a las propiedades del modelo [caravana].
  @override
  Widget build(BuildContext context) {
    // Transforma la fecha del modelo en un String legible (Ej: 24-10-2023)
    String fechaFormateada =
        DateFormat('dd-MM-yyyy').format(caravana.hf_lectura);
    // Transforma la hora del modelo en un String legible (Ej: 12:34:56)
    String horaFormateada = DateFormat('HH:mm:ss').format(caravana.hf_lectura);

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Añade un margen inferior de 12 píxeles
      decoration: BoxDecoration( // Define el estilo del contenedor
        color: AppTheme.surface, // Define el color de fondo
        borderRadius: BorderRadius.circular(12), // Define el radio de las esquinas
        border: Border( // Define el borde del contenedor
          left: BorderSide( // Define el borde izquierdo
              color: caravana.esOk ?  // Define el color dependiendo si esta seleccionada el item
                Colors.green // Si es correcto, el borde izquierdo es verde
                : 
                Colors.red, // Si es incorrecto, el borde izquierdo es rojo
                width: 5), // Define el grosor del borde
        ),
      ),
      child: Padding( // Define el padding interno del contenedor
        padding: const EdgeInsets.all(16.0), // Define el padding interno del contenedor
        child: Row( // Define la fila de widgets
          children: [ // Define los widgets que componen la fila
            Checkbox( // Define el checkbox
              value: caravana.seleccionada, // Define el valor del checkbox sacando el valor de de CaravanaModel.seleccionada
              onChanged: (_) => onToggle(), // Define la accion al cambiar el valor del checkbox
              activeColor: AppTheme.primary, // Define el color activo del checkbox
            ),
            const SizedBox(width: 8), // Define el espacio entre el checkbox y el texto
            Expanded( // Define el espacio entre el checkbox y el texto
              child: Column( // Define la columna de widgets
                crossAxisAlignment: CrossAxisAlignment.start, // Define el alineamiento de los widgets
                children: [
                  Row(
                    children: [
                      _buildChip("GIA: ${caravana.gia}"),
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(horaFormateada,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(caravana.caravana,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace')),
                  Text(fechaFormateada,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              children: [
                _buildStatusBadge(caravana.esOk),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

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

  Widget _buildStatusBadge(bool isOk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOk ? AppTheme.okBg : AppTheme.errorBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOk ? "OK" : "FALTANTE",
        style: TextStyle(
            color: isOk ? AppTheme.okText : AppTheme.errorText,
            fontSize: 9,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
