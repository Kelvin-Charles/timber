import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/role_permissions.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AppDrawer extends StatelessWidget {
  final User? user;
  
  const AppDrawer({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final String userRole = user?.role ?? 'worker';
    final Map<String, bool> permissions = RolePermissions.getPermissions(userRole);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.fullName ?? user?.username ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user?.role.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Dashboard - visible to all
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context, 
                '/dashboard',
                arguments: user,
              );
            },
          ),
          
          // Logs - visible to all
          if (permissions['logs_view'] == true)
            ListTile(
              leading: const Icon(Icons.forest),
              title: const Text('Logs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context, 
                  '/logs',
                  arguments: user,
                );
              },
            ),
          
          // Inventory - visible to all
          if (permissions['inventory_view'] == true)
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () {
                Navigator.pushNamed(context, '/inventory');
              },
            ),
          
          // Production - visible to all
          if (permissions['production_view'] == true)
            ListTile(
              leading: const Icon(Icons.precision_manufacturing),
              title: const Text('Production'),
              onTap: () {
                Navigator.pushNamed(context, '/production');
              },
            ),
          
          // Customers - visible to all
          if (permissions['customers_view'] == true)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () {
                Navigator.pushNamed(context, '/customers');
              },
            ),
          
          // Orders - visible to all
          if (permissions['orders_view'] == true)
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
          
          const Divider(),
          
          // Reports - visible to managers and above
          if (permissions['reports_view'] == true)
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pushNamed(context, '/reports');
              },
            ),
          
          // User Management - visible to admins and directors
          if (permissions['users_view'] == true)
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
          
          // Settings - visible to admins and directors
          if (permissions['settings_view'] == true)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          
          const Divider(),
          
          // Logout - visible to all
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // Implement logout logic
              final apiService = ApiService();
              await apiService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
} 