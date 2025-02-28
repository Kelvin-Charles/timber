import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../utils/role_permissions.dart';
import '../services/notification_service.dart';

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
    return Scaffold(
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
              // Welcome card
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              
              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: 24),
              
              // Inventory summary
              _buildSectionTitle('Inventory Summary'),
              _buildSummaryCards(_inventorySummary, Colors.blue),
              const SizedBox(height: 24),
              
              // Logs summary
              _buildSectionTitle('Logs Summary'),
              _buildSummaryCards(_logsSummary, AppTheme.primaryColor),
              const SizedBox(height: 24),
              
              // Production summary
              _buildSectionTitle('Production Summary'),
              _buildSummaryCards(_productionSummary.map((key, value) => 
                MapEntry(key, value.toInt())), AppTheme.secondaryColor),
              const SizedBox(height: 24),
              
              // Recent orders
              _buildSectionTitle('Recent Orders'),
              _buildRecentOrders(),

              // Admin and Director specific stats
              if (RolePermissions.hasRole(widget.user?.role ?? '', 'admin')) {
                _buildSectionTitle('System Statistics'),
                _buildAdminStats(),
                const SizedBox(height: 24),
              }

              // Director specific financial overview
              if (RolePermissions.hasRole(widget.user?.role ?? '', 'director')) {
                _buildSectionTitle('Financial Overview'),
                _buildFinancialOverview(),
                const SizedBox(height: 24),
              }
            ],
          ),
        ),
      ),
      floatingActionButton: RoleBasedWidget(
        userRole: widget.user?.role ?? '',
        requiredRole: 'admin',
        child: FloatingActionButton(
          onPressed: _createSampleNotification,
          tooltip: 'Create Sample Notification',
          child: const Icon(Icons.notification_add),
        ),
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

  Widget _buildSummaryCards(Map<String, int> data, Color baseColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        final opacity = 1.0 - (index * 0.2).clamp(0.0, 0.6);
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to detailed view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing details for ${entry.key}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: baseColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: baseColor.withOpacity(opacity),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentOrders.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = _recentOrders[index];
          
          // Determine status color
          Color statusColor;
          switch (order['status']) {
            case 'Delivered':
              statusColor = Colors.green;
              break;
            case 'Processing':
              statusColor = Colors.blue;
              break;
            case 'Pending':
              statusColor = Colors.orange;
              break;
            default:
              statusColor = Colors.grey;
          }
          
          return ListTile(
            onTap: () {
              // Navigate to order details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing order ${order['id']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            title: Text(
              order['customer'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${order['id']} • ${order['date']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminStats() {
    // Admin-specific statistics
    final Map<String, int> adminStats = {
      'Total Users': 12,
      'Active Sessions': 5,
      'System Alerts': 2,
    };
    
    return _buildSummaryCards(adminStats, AppTheme.infoColor);
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
} 