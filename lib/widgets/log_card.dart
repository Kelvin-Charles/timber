import 'package:flutter/material.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';

class LogCard extends StatelessWidget {
  final Log log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LogCard({
    super.key,
    required this.log,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log #${log.logNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusChip(log.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Species: ${log.species}'),
            Text('Dimensions: ${log.diameter} cm × ${log.length} m'),
            Text('Quality: ${log.quality}'),
            Text('Source: ${log.source}'),
            Text('Received: ${log.receivedDate}'),
            if (log.notes != null && log.notes!.isNotEmpty)
              Text('Notes: ${log.notes}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        break;
      case 'in production':
        color = Colors.blue;
        break;
      case 'sold':
        color = Colors.purple;
        break;
      case 'damaged':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
} 