import 'package:flutter/material.dart';
import '../../../models/caravana_models.dart';

class TempCaravanaItem extends StatelessWidget {
  final CaravanaModel caravana;
  final VoidCallback onDelete;

  const TempCaravanaItem({
    super.key, 
    required this.caravana, 
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Altura fija para consistencia visual
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: Row(
        children: [
          // Info Principal
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caravana.caravana,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15,
                    color: Colors.black87
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "${caravana.hf_lectura.day}/${caravana.hf_lectura.month} ${caravana.hf_lectura.hour}:${caravana.hf_lectura.minute.toString().padLeft(2,'0')}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: Colors.grey[300]), // Separador
                    const SizedBox(width: 8),
                    Text(
                      "GIA: ${caravana.gia}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Botón Eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
            splashRadius: 20,
          )
        ],
      ),
    );
  }
}