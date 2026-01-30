// fonten_flutter\lib\screens\config_drawer\config_drawer_screen.dart

import 'package:flutter/material.dart';
import 'package:fonten_flutter/screens/config_drawer/config_drawer_handler.dart';
import 'package:provider/provider.dart';
import '../snig/snig_handler.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ConfigDrawer extends StatelessWidget {
  const ConfigDrawer({super.key});

  //<!> Esto lo agrego la ia no se lo que es
  static final WidgetStateProperty<Icon?> _thumbIcon =
      WidgetStateProperty.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: const Icon(Icons.check, color: Colors.white),
      WidgetState.any: const Icon(Icons.close, color: Colors.white),
    },
  );

  @override
  Widget build(BuildContext context) {
    // final handler = Provider.of<SnigHandler>(context); <!> Estes lo anteriro borrar cuando aga andar estra nueva restructuracion
    final drawerHandler = Provider.of<ConfigDrawerHandler>(context);
    // <!> Esto creo que es donde vinculo snig_handler con config_drawer_handler no me queda claro como poer supuestamte me ace que notifique a snig_screen
    final snigHandler = Provider.of<SnigHandler>(context,
        listen: false); // listen: false es clave acá

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
                const Text("EDICIÓN DE LOTE",
                    style: TextStyle(
                        fontSize: 20,
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
                const SizedBox(height: 5),

                //Botones de Importar y Exportar ----
                Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Alinea el contenido a la izquierda
                  children: [
                    // Boton de Carga (CSV) ----
                    _buildActionButton(
                      context: context,
                      label: "CARGAR CSV",
                      icon: Icons.table_view,
                      action: () async {
                        await drawerHandler.cargarArchivoCsv();
                        snigHandler.refrescarDesdeService();
                      },
                    ),
                    const SizedBox(height: 8),

                    // Boton de Carga  Simulador (PDF) ----
                    _buildActionButton(
                      context: context,
                      label: "CARGAR SIMULADOR (${snigHandler.totalCaravanasSeleccionadas})",
                      icon: Icons.picture_as_pdf,
                      action: snigHandler.totalCaravanasSeleccionadas > 0 ? // Si hay caravanas seleccionadas 
                      () async { // Logica de cargar Simulador PDF 
                        await drawerHandler.cargarArchivoPdf();
                        snigHandler.refrescarDesdeService();
                      }
                      :
                      null, // Si no hay Caravanas seleccionada
                      color: snigHandler.totalCaravanasSeleccionadas > 0
                          ? null
                          : Colors.grey,
                    ),
                    

                    // Boton de Carga (TXT) ----
                    const SizedBox(height: 8),
                    _buildActionButton(
                      context: context,
                      label: "IMPORTAR TXT",
                      icon: Icons.note_add,
                      action: () async {
                        await drawerHandler.cargarArchivoTxt();
                        snigHandler.refrescarDesdeService();
                      },
                    ),

                    // Boton de Exportar (TXT) ----
                    const SizedBox(height: 8),
                    _buildActionButton(
                      context: context,
                      label: "EXPORTAR TXT (${snigHandler.totalCaravanasSeleccionadas})",
                      icon: Icons.download,
                      action: snigHandler.totalCaravanasSeleccionadas > 0 ? 
                        drawerHandler.exportarArchivoTxt : 
                        null,
                      color: snigHandler.totalCaravanasSeleccionadas > 0
                          ? null
                          : Colors.grey,
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                // Caja Edicion masiva ----
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // CABECERA VERDE (El "Label" con bordes redondeados superiores)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: const BoxDecoration(
                          color:
                              AppTheme.primary, // O el verde que estés usando
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          "EDICIÓN DE LOTE (${snigHandler.totalCaravanasSeleccionadas})",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      // CUERPO DE LA CAJA (Con menos espacio entre elementos)
                      Padding(
                        padding: const EdgeInsets.all(
                            10.0), // Achicamos el padding general
                        child: Column(
                          children: [
                            _buildGiaEditSection(
                                drawerHandler), // <!> Porque este no resive context?
                            _buildDateEditSection(drawerHandler, context),
                            _buildTimeEditSection(drawerHandler, context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Aquí irían los controles de selector de hora que dibujaste...
              ],
            ),
          ),

          // Botón Aplicar Cambios
          _buildApplyButton(context, drawerHandler, snigHandler),
        ],
      ),
    );
  }
  /// Construye la sección de edición masiva para el campo GIA.
  /// 
  /// Incluye un interruptor (Switch) para habilitar la funcionalidad 
  /// y un campo de texto para ingresar el nuevo valor que se aplicará 
  /// a las caravanas seleccionadas.
  /// 
  /// Parámetros:
  ///   handler - El manejador de la configuración del drawer.
  /// 
  /// Retorna:
  ///   Un widget que representa la sección de edición masiva para el campo GIA.
  Widget _buildGiaEditSection(ConfigDrawerHandler handler) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2), // Margen vertical
      padding: const EdgeInsets.all(2), // Padding interno
      child: Column(
        children: [
          // --- FILA GIA (Label + Switch) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cambiar GIA",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                thumbIcon: WidgetStateProperty.fromMap(
                  <WidgetStatesConstraint, Icon>{
                    WidgetState.selected:
                        const Icon(Icons.check, color: Colors.white),
                    WidgetState.any:
                        const Icon(Icons.close, color: Colors.white),
                  },
                ),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                value: handler.isGiaEditEnabled,
                onChanged: (val) => handler.setGiaEditEnabled(val),
              ),
            ],
          ),

          // --- FILA NUEVO GIA (TextField) ---
          TextField(
            enabled: handler.isGiaEditEnabled,
            onChanged: (val) => handler.setGia(val),
            decoration: InputDecoration(
              hintText: "Nuevo GIA (Ej: C204416)",
              filled: true, // Relleno del campo
              isDense: true, // Reducir el padding interno del campo
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12), // Padding interno del campo
              fillColor: handler.isGiaEditEnabled
                  ? Colors.white
                  : Colors.grey[100], // Color del relleno
              prefixIcon: Icon(Icons.description, // Color del icono
                  color: handler.isGiaEditEnabled
                      ? // Depende si el switch esta activado o no
                      Colors.green
                      : Colors.grey,
                  size: 20), // Tamaño del icono
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Radio de la esquina
                borderSide: BorderSide(
                    color: Colors.grey.shade300), // Borde del contenedor
              ),
            ),
            style: TextStyle(
              fontSize: 16, // Tamaño de la fuente
              fontWeight: FontWeight.bold,
              color: handler.isGiaEditEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateEditSection(
      ConfigDrawerHandler handler, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          // --- FILA FECHA (Label + Switch) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cambiar Fecha",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                thumbIcon: _thumbIcon, // Usamos la variable global de icono
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                value: handler.isDateEditEnabled,
                onChanged: (val) => handler.setDateEditEnabled(val),
              ),
            ],
          ),

          // --- FILA NUEVA FECHA (TextField con Tap) ---
          TextField(
            readOnly:
                true, // Para que no se abra el teclado, solo el calendario
            onTap: handler.isDateEditEnabled
                ? () => _selectDate(context, handler)
                : null,
            decoration: InputDecoration(
              hintText: DateFormat('dd/MM/yyyy').format(handler.selectedDate),
              filled: true,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              fillColor:
                  handler.isDateEditEnabled ? Colors.white : Colors.grey[100],
              prefixIcon: Icon(Icons.calendar_today,
                  color: handler.isDateEditEnabled ? Colors.green : Colors.grey,
                  size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: handler.isDateEditEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEditSection(
      ConfigDrawerHandler handler, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          // --- FILA HORA (Label + Switch) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Hora Inicial Masiva",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                thumbIcon: _thumbIcon,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                value: handler.isTimeEditEnabled,
                onChanged: (val) => handler.setTimeEditEnabled(val),
              ),
            ],
          ),

          // --- FILA NUEVA HORA (TextField con Tap) ---
          TextField(
            readOnly: true,
            onTap: handler.isTimeEditEnabled
                ? () => _selectTime(context, handler)
                : null,
            decoration: InputDecoration(
              hintText: handler.selectedTime.format(context),
              filled: true,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              fillColor:
                  handler.isTimeEditEnabled ? Colors.white : Colors.grey[100],
              prefixIcon: Icon(Icons.access_time,
                  color: handler.isTimeEditEnabled ? Colors.green : Colors.grey,
                  size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: handler.isTimeEditEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un selector de hora para seleccionar una nueva hora.
  /// 
  /// Parámetros:
  ///   context - El contexto de la aplicación.
  ///   handler - El manejador de la configuración del drawer.
  /// 
  /// Retorna:
  ///   Un widget que representa el selector de hora.
  Future<void> _selectTime(
      BuildContext context, ConfigDrawerHandler handler) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: handler.selectedTime,
    );
    if (picked != null && picked != handler.selectedTime) {
      handler.setSelectedTime(picked);
    }
  }

  Future<void> _selectDate(
      BuildContext context, ConfigDrawerHandler handler) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: handler.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != handler.selectedDate) {
      handler.setDate(picked);
    }
  }

  Widget _buildApplyButton(BuildContext context, ConfigDrawerHandler handler,
      SnigHandler snigHandler) {
    int xTotalCaravanasSeleccionadas = snigHandler.totalCaravanasSeleccionadas;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: xTotalCaravanasSeleccionadas > 0 ? // Si tiene caravanas seleccionadas
          () => _handleApplyButton(context, handler, snigHandler) :
          null,
        style: ElevatedButton.styleFrom(
          backgroundColor: xTotalCaravanasSeleccionadas > 0 ?  // Si tiene caravanas seleccionadas
          const Color(0xFF121714) : // Si tiene caravanas seleccionadas
          const Color.fromARGB(255, 74, 72, 72), // Si no tiene caravanas seleccionadas
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text("APLICAR CAMBIOS (${xTotalCaravanasSeleccionadas})",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

// Esto lo saque de config_drawer_screen.dart no se para que es 27-01

  void _handleApplyButton(BuildContext context, ConfigDrawerHandler handler,
      SnigHandler snigHandler) {
    // 1. Ejecutamos la lógica que creamos arriba
    handler.applyChanges();

    // 2. Refrescamos la lista principal
    snigHandler.refrescarDesdeService();

    // 2. Mostramos un mensaje rápido de éxito (Opcional pero recomendado)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cambios aplicados correctamente"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 3. Cerramos el Drawer
    Navigator.pop(context);
  }

  /// Construye un botón de acción estandarizado para la gestión de archivos.
  ///
  /// Este widget centraliza la lógica visual y funcional de los botones del Drawer.
  /// [label]: El texto que se mostrará en el botón.
  /// [icon]: El icono representativo de la acción (PDF, CSV, etc.).
  /// [action]: Función asincrónica que ejecuta la lógica de negocio (SnigHandler).
  ///
  /// Lógica integrada:
  /// 1. Ejecuta la [action] de forma asincrónica.
  /// 2. Si la acción es exitosa, cierra automáticamente el menú lateral (Drawer).
  /// 3. Gestiona errores internos para evitar cierres inesperados de la aplicación.
  /// 4. Desactiva visualmente el botón si la [action] es nula.
  Widget _buildActionButton(
      {required BuildContext context, // Contexto de la pantalla
      required String label, // Texto del boton
      required IconData icon, // Icono del boton
      required Future<void> Function()? action, // Ahora recibe un Future<void>
      Color? color}) {
    return InkWell(
      onTap: action == null
          ? null
          : () async {
              try {
                // 1. Ejecutamos la función que le pasamos (cargar CSV, PDF, etc.)
                await action();

                // 2. Si llegamos acá es porque no hubo error, cerramos el Drawer
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                // 3. Si hubo error, lo mostramos y NO cerramos el Drawer
                debugPrint("Error en la acción $label: $e");
                // Opcional: Podés mostrar un SnackBar acá con el error
              }
            },
      borderRadius: BorderRadius.circular(12), // Radio de la esquina
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? AppTheme.primary, // Color del boton
          borderRadius: BorderRadius.circular(12), // Radio de la esquina
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}





// 01-27
// Witget para sentralizar los campos editar masiva 
// sentraliza el specto de los controles porque son iguales 
// implmentar despues cuando se pretenda cambiar la estecia 
// --- <Implementar> ---

    // Widget _buildBaseEditSection({
    //   required String label,
    //   required bool isEnabled,
    //   required Function(bool) onSwitchChanged,
    //   required String hintText,
    //   required IconData icon,
    //   // Comportamientos opcionales:
    //   void Function()? onTap,           // Para Fecha y Hora
    //   void Function(String)? onChanged, // Para el GIA (Texto)
    //   bool isReadOnly = false,          // Por defecto deja escribir, salvo que le digamos lo contrario
    // }) {
    //   return Container(
    //     margin: const EdgeInsets.symmetric(vertical: 2),
    //     padding: const EdgeInsets.all(2),
    //     child: Column(
    //       children: [
    //         // --- CABECERA (Texto + Switch propio) ---
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    //             Switch(
    //               thumbIcon: _thumbIcon,
    //               activeColor: Colors.green,
    //               inactiveThumbColor: Colors.red,
    //               value: isEnabled,
    //               onChanged: onSwitchChanged, // Cada uno maneja su propio bool
    //             ),
    //           ],
    //         ),

    //         // --- CAMPO (Se adapta al comportamiento) ---
    //         TextField(
    //           enabled: isEnabled,
    //           readOnly: isReadOnly, // Si es fecha/hora, bloqueamos el teclado
    //           onTap: isEnabled ? onTap : null, // Si es fecha/hora, ejecuta el picker
    //           onChanged: onChanged, // Si es GIA, guarda el texto
    //           decoration: InputDecoration(
    //             hintText: hintText,
    //             filled: true,
    //             isDense: true,
    //             contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    //             fillColor: isEnabled ? Colors.white : Colors.grey[100],
    //             prefixIcon: Icon(icon, 
    //               color: isEnabled ? Colors.green : Colors.grey, 
    //               size: 20),
    //             border: OutlineInputBorder(
    //               borderRadius: BorderRadius.circular(12),
    //               borderSide: BorderSide(color: Colors.grey.shade300),
    //             ),
    //           ),
    //           style: TextStyle(
    //             fontSize: 16,
    //             fontWeight: FontWeight.bold,
    //             color: isEnabled ? Colors.black : Colors.grey,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // Widget _buildGiaEditSection(ConfigDrawerHandler handler) {
    //   return _buildBaseEditSection(
    //     label: "Cambiar GIA",
    //     isEnabled: handler.isGiaEditEnabled,
    //     onSwitchChanged: (val) => handler.setGiaEditEnabled(val),
    //     hintText: "Nuevo GIA (Ej: C204416)",
    //     icon: Icons.description,
    //     isReadOnly: false, // DEJA ESCRIBIR
    //     onChanged: (val) => handler.setGia(val), // GUARDA TEXTO
    //   );
    // }

    // Widget _buildDateEditSection(ConfigDrawerHandler handler, BuildContext context) {
    //   return _buildBaseEditSection(
    //     label: "Cambiar Fecha",
    //     isEnabled: handler.isDateEditEnabled,
    //     onSwitchChanged: (val) => handler.setDateEditEnabled(val),
    //     hintText: DateFormat('dd/MM/yyyy').format(handler.selectedDate),
    //     icon: Icons.calendar_today,
    //     isReadOnly: true, // BLOQUEA TECLADO
    //     onTap: () => _selectDate(context, handler), // ABRE CALENDARIO
    //   );
    // }

    // Widget _buildTimeEditSection(ConfigDrawerHandler handler, BuildContext context) {
    //   return _buildBaseEditSection(
    //     label: "Hora Inicial Masiva",
    //     isEnabled: handler.isTimeEditEnabled,
    //     onSwitchChanged: (val) => handler.setTimeEditEnabled(val),
    //     hintText: handler.selectedTime.format(context),
    //     icon: Icons.access_time,
    //     isReadOnly: true, // BLOQUEA TECLADO
    //     onTap: () => _selectTime(context, handler), // ABRE RELOJ
    //   );
    // }

 // </FIN Implementar> 