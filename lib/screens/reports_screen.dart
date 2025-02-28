import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../utils/role_permissions.dart';

class ReportsScreen extends StatefulWidget {
  final User? user;
  
  const ReportsScreen({super.key, this.user});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<String> _reportTypes = [
    'Sales Report',
    'Inventory Report',
    'Production Report',
    'Customer Report',
    'Financial Report',
  ];
  
  String _selectedReportType = 'Sales Report';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Generate Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Report Type',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedReportType,
                        items: _reportTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReportType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () {
                                // Show date picker
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Generate report
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Generating $_selectedReportType...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Generate Report'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text('${_reportTypes[index % _reportTypes.length]} - ${DateTime.now().subtract(Duration(days: index * 3)).toString().substring(0, 10)}'),
                        subtitle: Text('Generated by ${widget.user?.fullName ?? 'Admin'}'),
                        trailing: const Icon(Icons.download),
                        onTap: () {
                          // Download report
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloading report...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 