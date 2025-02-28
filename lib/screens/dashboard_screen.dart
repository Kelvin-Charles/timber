import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../utils/role_permissions.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/role_based_action_button.dart';
import '../widgets/notification_bell.dart';

class DashboardScreen extends StatefulWidget {
  final User? user;
  
  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Sample data for dashboard
  final Map<String, int> _inventorySummary = {
    'Raw Materials': 25,
    'Finished Products': 42,
    'Low Stock Items': 8,
  };
  
  final Map<String, int> _logsSummary = {
    'In Stock': 35,
    'In Production': 12,
    'Sold': 18,
  };
  
  final Map<String, double> _productionSummary = {
    'Not Started': 5,
    'In Progress': 8,
    'On Hold': 2,
    'Completed': 15,
  };
  
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'ORD-001',
      'customer': 'John Smith',
      'date': '2023-06-15',
      'amount': 1250.00,
      'status': 'Delivered',
    },
    {
      'id': 'ORD-002',
      'customer': 'Acme Furniture',
      'date': '2023-06-18',
      'amount': 3450.75,
      'status': 'Processing',
    },
    {
      'id': 'ORD-003',
      'customer': 'Jane Doe',
      'date': '2023-06-20',
      'amount': 875.50,
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get the user's role
    final String userRole = widget.user?.role ?? 'worker';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [
          NotificationBell(),
        ],
      ),
      drawer: AppDrawer(user: widget.user),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic here
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            // Update data if needed
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card - visible to all roles
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              
              // Quick stats - visible to all roles
              _buildQuickStats(),
              const SizedBox(height: 24),
              
              // Inventory summary - visible to all roles
              _buildSectionTitle('Inventory Summary'),
              _buildSummaryCards(_inventorySummary, Colors.blue),
              const SizedBox(height: 24),
              
              // Logs summary - visible to all roles
              _buildSectionTitle('Logs Summary'),
              _buildSummaryCards(_logsSummary, AppTheme.primaryColor),
              const SizedBox(height: 24),
              
              // Production summary - visible to all roles
              _buildSectionTitle('Production Summary'),
              _buildSummaryCards(_productionSummary.map((key, value) => 
                MapEntry(key, value.toInt())), AppTheme.secondaryColor),
              const SizedBox(height: 24),
              
              // Recent orders - visible to all roles
              _buildSectionTitle('Recent Orders'),
              _buildRecentOrders(),

              // Admin-specific content
              if (RolePermissions.hasRole(userRole, 'admin'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionTitle('Admin Controls'),
                    _buildAdminControls(),
                  ],
                ),
              
              // Director-specific content
              if (RolePermissions.hasRole(userRole, 'director'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionTitle('Financial Overview'),
                    _buildFinancialOverview(),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'logs_add',
        onPressed: () {
          _showAddActionDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    String greeting;
    
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: Text(
                    widget.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      widget.user?.fullName ?? widget.user?.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to NgaraTimber Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Today is ${_formatDate(DateTime.now())}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            title: 'Total Logs',
            value: '65',
            icon: Icons.forest,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            title: 'Active Orders',
            value: '12',
            icon: Icons.shopping_cart,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            title: 'Customers',
            value: '28',
            icon: Icons.people,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, int> data, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            return InkWell(
              onTap: () {
                // Navigate based on card type
                if (color == Colors.blue) {
                  // Inventory cards
                  Navigator.pushNamed(context, '/inventory', arguments: widget.user);
                } else if (color == AppTheme.primaryColor) {
                  // Logs cards
                  Navigator.pushNamed(context, '/logs', arguments: widget.user);
                } else if (color == AppTheme.secondaryColor) {
                  // Production cards
                  Navigator.pushNamed(context, '/production', arguments: widget.user);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orders', arguments: widget.user);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            ..._recentOrders.map((order) {
              return InkWell(
                onTap: () {
                  // Navigate to order details
                  Navigator.pushNamed(
                    context, 
                    '/orders/details', 
                    arguments: {'user': widget.user, 'orderId': order['id']},
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          order['id'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(order['customer']),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('\$${order['amount'].toStringAsFixed(2)}'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(order['status']),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminControls() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // User statistics
            Row(
              children: [
                _buildAdminStatCard(
                  'Total Users',
                  '12',
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildAdminStatCard(
                  'Active Sessions',
                  '5',
                  Icons.devices,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildAdminStatCard(
                  'System Alerts',
                  '2',
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Admin action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAdminActionButton(
                  'User Management',
                  Icons.manage_accounts,
                  () {
                    Navigator.pushNamed(context, '/users');
                  },
                ),
                _buildAdminActionButton(
                  'System Settings',
                  Icons.settings,
                  () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _buildAdminActionButton(
                  'Backup Data',
                  Icons.backup,
                  () {
                    _showBackupDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup System Data'),
        content: const Text('Do you want to create a backup of all system data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup started. This may take a few minutes.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('BACKUP'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    // Financial data for directors
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue: \$24,850',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'YTD Profit: \$142,320',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Top Performing Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPerformanceBar('Oak Boards', 0.85, AppTheme.primaryColor),
            const SizedBox(height: 4),
            _buildPerformanceBar('Pine Planks', 0.65, AppTheme.accentColor),
            const SizedBox(height: 4),
            _buildPerformanceBar('Maple Veneer', 0.45, AppTheme.secondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _createSampleNotification() {
    final notificationService = NotificationService();
    
    // Create a sample stock update notification
    notificationService.createStockUpdateNotification(
      itemName: 'Pine Planks',
      oldQuantity: 150,
      newQuantity: 175,
      unit: 'piece',
      location: 'Warehouse A',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample notification created'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddActionDialog() {
    final String userRole = widget.user?.role ?? 'worker';
    final Map<String, bool> permissions = RolePermissions.getPermissions(userRole);
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add New'),
        children: [
          if (permissions['logs_add'] == true)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/logs/add');
              },
              child: const ListTile(
                leading: Icon(Icons.forest),
                title: Text('New Log'),
              ),
            ),
          
          if (permissions['inventory_add'] == true)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventory/add');
              },
              child: const ListTile(
                leading: Icon(Icons.inventory),
                title: Text('New Inventory Item'),
              ),
            ),
          
          if (permissions['production_add'] == true)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/production/add');
              },
              child: const ListTile(
                leading: Icon(Icons.precision_manufacturing),
                title: Text('New Production'),
              ),
            ),
          
          if (permissions['customers_add'] == true)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/customers/add');
              },
              child: const ListTile(
                leading: Icon(Icons.people),
                title: Text('New Customer'),
              ),
            ),
          
          if (permissions['orders_add'] == true)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orders/add');
              },
              child: const ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('New Order'),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 