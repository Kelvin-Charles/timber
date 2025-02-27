import 'package:flutter/material.dart';
import '../models/log.dart';
import '../services/api_service.dart';
import 'screens/login_screen.dart';
import 'models/user.dart';

void main() {
  runApp(const WoodManagementApp());
}

class WoodManagementApp extends StatelessWidget {
  const WoodManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wood Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          primary: Colors.brown,
          secondary: Colors.green.shade700,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late User _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _currentUser = args;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wood Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Show profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardScreen(),
          LogTrackingScreen(),
          InventoryScreen(),
          ProductionScreen(),
          CustomersScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forest),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Production',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
        ],
      ),
    );
  }
}

// Home/Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Stats Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                'Logs in Inventory',
                '245',
                Icons.forest,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Products in Progress',
                '32',
                Icons.construction,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Completed Orders',
                '18',
                Icons.check_circle,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Pending Orders',
                '7',
                Icons.pending_actions,
                Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Recent Activity Section
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildActivityItem(
            'New log shipment received',
            '2 hours ago',
            Icons.local_shipping,
          ),
          _buildActivityItem(
            'Order #1234 completed',
            '5 hours ago',
            Icons.check_circle,
          ),
          _buildActivityItem(
            'Inventory count updated',
            'Yesterday',
            Icons.update,
          ),
          _buildActivityItem(
            'New customer order received',
            'Yesterday',
            Icons.shopping_cart,
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                context,
                'Add Log',
                Icons.add_circle,
                () {
                  // TODO: Navigate to add log screen
                },
              ),
              _buildQuickAction(
                context,
                'New Order',
                Icons.post_add,
                () {
                  // TODO: Navigate to new order screen
                },
              ),
              _buildQuickAction(
                context,
                'Reports',
                Icons.bar_chart,
                () {
                  // TODO: Navigate to reports screen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.brown),
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Show activity details
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

// Update the LogTrackingScreen class
class LogTrackingScreen extends StatefulWidget {
  const LogTrackingScreen({super.key});

  @override
  State<LogTrackingScreen> createState() => _LogTrackingScreenState();
}

class _LogTrackingScreenState extends State<LogTrackingScreen> {
  final ApiService _apiService = ApiService();
  List<Log> _logs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final logs = await _apiService.getLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLogs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _logs.isEmpty
                    ? const Center(child: Text('No logs found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              title: Text(
                                'Log #${log.logNumber} - ${log.species}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Size: ${log.diameter}cm × ${log.length}m'),
                                  Text('Status: ${log.status}'),
                                  Text('Received: ${log.receivedDate}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showLogForm(context, log);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _confirmDelete(context, log);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showLogDetails(context, log);
                              },
                            ),
                          );
                        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLogDetails(BuildContext context, Log log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log #${log.logNumber}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _detailRow('Species', log.species),
              _detailRow('Diameter', '${log.diameter} cm'),
              _detailRow('Length', '${log.length} m'),
              _detailRow('Quality', log.quality),
              _detailRow('Source', log.source),
              _detailRow('Status', log.status),
              _detailRow('Received Date', log.receivedDate),
              if (log.notes != null && log.notes!.isNotEmpty)
                _detailRow('Notes', log.notes!),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogForm(context, log);
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
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

  void _showLogForm(BuildContext context, [Log? log]) {
    final _formKey = GlobalKey<FormState>();
    final isEditing = log != null;
    
    // Form controllers
    final logNumberController = TextEditingController(text: isEditing ? log.logNumber : '');
    final speciesController = TextEditingController(text: isEditing ? log.species : '');
    final diameterController = TextEditingController(text: isEditing ? log.diameter.toString() : '');
    final lengthController = TextEditingController(text: isEditing ? log.length.toString() : '');
    final qualityController = TextEditingController(text: isEditing ? log.quality : '');
    final sourceController = TextEditingController(text: isEditing ? log.source : '');
    final statusController = TextEditingController(text: isEditing ? log.status : 'Available');
    final receivedDateController = TextEditingController(text: isEditing ? log.receivedDate : DateTime.now().toString().substring(0, 10));
    final notesController = TextEditingController(text: isEditing && log.notes != null ? log.notes! : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Log' : 'Add New Log',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: logNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Log Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a log number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: speciesController,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the species';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: diameterController,
                          decoration: const InputDecoration(
                            labelText: 'Diameter (cm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: lengthController,
                          decoration: const InputDecoration(
                            labelText: 'Length (m)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: qualityController,
                    decoration: const InputDecoration(
                      labelText: 'Quality',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quality';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sourceController,
                    decoration: const InputDecoration(
                      labelText: 'Source',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the source';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: receivedDateController,
                    decoration: const InputDecoration(
                      labelText: 'Received Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        receivedDateController.text = date.toString().substring(0, 10);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final newLog = Log(
                                id: isEditing ? log.id : null,
                                logNumber: logNumberController.text,
                                species: speciesController.text,
                                diameter: double.parse(diameterController.text),
                                length: double.parse(lengthController.text),
                                quality: qualityController.text,
                                source: sourceController.text,
                                status: statusController.text,
                                receivedDate: receivedDateController.text,
                                notes: notesController.text.isEmpty ? null : notesController.text,
                              );
                              
                              if (isEditing) {
                                await _apiService.updateLog(newLog);
                              } else {
                                await _apiService.addLog(newLog);
                              }
                              
                              Navigator.pop(context);
                              _loadLogs();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'Log updated successfully' : 'Log added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(isEditing ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Log log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete Log #${log.logNumber}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _apiService.deleteLog(log.id!);
                  Navigator.pop(context);
                  _loadLogs();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Log deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Placeholder screens for other sections
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Inventory Management Screen - Coming Soon'),
    );
  }
}

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Production Workflow Screen - Coming Soon'),
    );
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Customer Management Screen - Coming Soon'),
    );
  }
}
