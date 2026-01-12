import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/caravana_models.dart';
import '../../core/theme/app_theme.dart';

class CaravanaItem extends StatelessWidget {
  final CaravanaModel caravana;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const CaravanaItem(
      {super.key,
      required this.caravana,
      required this.onToggle,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Formatear la fecha y hora
    String fechaFormateada =
        DateFormat('dd-MM-yyyy').format(caravana.hf_lectura);
    String horaFormateada = DateFormat('HH:mm:ss').format(caravana.hf_lectura);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
              color: caravana.esOk ? Colors.green : Colors.red, width: 5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: caravana.seleccionada,
              onChanged: (_) => onToggle(),
              activeColor: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
