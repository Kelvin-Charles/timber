import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/log.dart';
import '../services/api_service.dart';

class LogDetailsScreen extends StatefulWidget {
  final User? user;
  final Log log;
  
  const LogDetailsScreen({
    super.key,
    required this.log,
    this.user,
  });

  @override
  State<LogDetailsScreen> createState() => _LogDetailsScreenState();
}

class _LogDetailsScreenState extends State<LogDetailsScreen> {
  bool _isLoading = false;
  
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Log ${widget.log.logNumber}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log ID and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log ID: ${widget.log.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.log.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor(widget.log.status)),
                        ),
                        child: Text(
                          widget.log.status.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(widget.log.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Log Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          _buildInfoRow('Log Number', widget.log.logNumber),
                          _buildInfoRow('Species', widget.log.species),
                          _buildInfoRow('Quality', widget.log.quality),
                          _buildInfoRow('Diameter', '${widget.log.diameter} cm'),
                          _buildInfoRow('Length', '${widget.log.length} cm'),
                          _buildInfoRow('Source', widget.log.source),
                          _buildInfoRow('Received Date', widget.log.receivedDate),
                          if (widget.log.notes != null && widget.log.notes!.isNotEmpty)
                            _buildInfoRow('Notes', widget.log.notes!),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Timestamps Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Timestamps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          if (widget.log.createdAt != null)
                            _buildInfoRow('Created At', widget.log.createdAt!),
                          if (widget.log.updatedAt != null)
                            _buildInfoRow('Updated At', widget.log.updatedAt!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 