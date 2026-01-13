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
class CaravanaItem extends StatelessWidget { //<!> Restructar con el disenio de figma 
  final CaravanaModel caravana; //<!> Cambiar por el modelo de datos
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
          
          // Checklist Caravana ------
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
                children: [ // Define los widgets que componen la columna
                  Row( // Define la fila de widgets
                    // Gia ------
                    children: [ // Define los widgets que componen la fila
                      _buildChip("GIA: ${caravana.gia}"), // Define el chip de GIA
                      const SizedBox(width: 8), // Define el espacio entre el chip y el icono
                      const Icon(Icons.schedule, size: 14, color: Colors.grey), // Define el icono de fecha
                      const SizedBox(width: 4),
                      // Hora Lectura ------
                      Text(horaFormateada, // Define el texto que se mostrará dentro del chip
                          style: const TextStyle( // Define el estilo del texto
                              fontSize: 12, // Define el tamaño del texto
                              color: Colors.grey // Define el color del texto
                            )
                          ),
                    ],
                  ),
                  const SizedBox(height: 4), // Define el espacio entre el chip y el texto
                  // Numero de Caravana ------
                  Text(caravana.caravana, // Define el texto que se mostrará dentro del chip
                      style: const TextStyle( // Define el estilo del texto
                          fontSize: 18, // Define el tamaño del texto
                          fontWeight: FontWeight.w800, // Define el peso del texto
                          fontFamily: 'monospace'// Define la fuente del texto
                          ) 
                      ),
                  // Fecha Lectura ------
                  Text(fechaFormateada, // Define el texto que se mostrará dentro del chip
                      style: const TextStyle( // Define el estilo del texto
                          fontSize: 12, // Define el tamaño del texto
                          color: Colors.grey // Define el color del texto
                        )
                      ),
                ],
              ),
            ),
            Column( // Define la columna de widgets
              // Acciones -----
              children: [ // Define los widgets que componen la columna
                // Estado de la caravana segun simulador OK o Faltante -----
                _buildStatusBadge(caravana.esOk), // Define el chip de estado
                // Boton de eliminacion -----
                IconButton( // Define el boton de eliminacion
                  icon: const Icon(Icons.delete_outline, color: Colors.grey), // Define el icono de eliminacion
                  onPressed: onDelete, // Define la accion al presionar el boton de eliminacion
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Construye un componente visual pequeño (Chip) para mostrar la guia de la lectrau
  /// relacionado a esa caravana 
  /// 
  /// La mete en un marco para que sea mas visible
  /// 
  /// Parámetros:
  /// * [label]: El texto que se mostrará dentro del chip.
  /// 
  /// Retorna un [Widget] que representa el chip con el texto proporcionado.
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Define el padding interno del contenedor
      decoration: BoxDecoration( // Define el estilo del contenedor
        color: Colors.grey[100], // Define el color de fondo
        borderRadius: BorderRadius.circular(4), // Define el radio de las esquinas
        border: Border.all(color: Colors.grey[300]!), // Define el borde del contenedor
      ),
      child: Text(label, // Define el texto que se mostrará dentro del chip
          style: const TextStyle(
            fontSize: 10, // Define el tamaño de la fuente
            fontWeight: FontWeight.bold // Define el peso de la fuente
            )),
    );
  }

  /// Construye un componente visual pequeño (Chip) para mostrar si la caravana 
  /// esta o no en el simulador
  /// 
  /// Parámetros:
  /// * [isOk]: Un booleano que indica si el estado es correcto o no.
  /// 
  /// Retorna un [Widget] que representa el chip con el texto proporcionado.
  Widget _buildStatusBadge(bool isOk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Define el padding interno del contenedor
      decoration: BoxDecoration( // Define el estilo del contenedor
        color: isOk ? // Define el color de fondo
          AppTheme.okBg : // Verde claro si la caravana esta en el simulador
          AppTheme.errorBg, // Rojo claro si la caravana no esta en el simulador
        borderRadius: BorderRadius.circular(20), // Define el radio de las esquinas
      ),
      child: Text( // Define el texto que se mostrará dentro del chip
        isOk ? // Define el texto que se mostrará dentro del chip
          "OK" : // Si la caravana esta en el simulador
          "FALTANTE", // Si la caravana no esta en el simulador
        style: TextStyle( // Define el estilo del texto
            color: isOk ?  // Define el color del texto
            AppTheme.okText : // Verde oscuro si la caravana esta en el simulador
            AppTheme.errorText, // Rojo oscuro si la caravana no esta en el simulador
            fontSize: 9, // Define el tamaño del texto
            fontWeight: FontWeight.bold), // Define el peso del texto
      ),
    );
  }
}
