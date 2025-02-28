import 'package:flutter/material.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../screens/log_details_screen.dart';

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':
        return Colors.green;
      case 'in_production':
        return Colors.blue;
      case 'sold':
        return Colors.orange;
      case 'reserved':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(log.status).withOpacity(0.2),
          child: Icon(
            Icons.agriculture,
            color: _getStatusColor(log.status),
          ),
        ),
        title: Text(log.logNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.species} • ${log.quality}'),
            Text('${log.diameter} cm × ${log.length} cm • ${log.source}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(log.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(log.status)),
              ),
              child: Text(
                log.status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(log.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: () {
          // Navigate to log details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogDetailsScreen(
                log: log,
              ),
            ),
          );
        },
      ),
    );
  }
} 