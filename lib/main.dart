import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/log.dart';
import 'models/user.dart';
import 'models/customer.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/log_form_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/inventory_form_screen.dart';
import 'screens/production_screen.dart';
import 'screens/production_form_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'screens/orders_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgaraTimber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        final User? user = args is User ? args : null;
        
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => DashboardScreen(user: user));
          case '/logs':
            return MaterialPageRoute(builder: (context) => LogsScreen(user: user));
          case '/logs/add':
            return MaterialPageRoute(
              builder: (context) => LogFormScreen(user: user),
            );
          case '/logs/edit':
            final Log? log = args is Map<String, dynamic> ? args['log'] as Log : null;
            return MaterialPageRoute(builder: (context) => LogFormScreen(user: user, log: log));
          case '/inventory':
            return MaterialPageRoute(builder: (context) => InventoryScreen(user: user));
          case '/inventory/add':
            return MaterialPageRoute(builder: (context) => InventoryFormScreen(user: user));
          case '/inventory/edit':
            final inventoryItem = args is Map<String, dynamic> ? args['item'] : null;
            return MaterialPageRoute(builder: (context) => InventoryFormScreen(user: user, item: inventoryItem));
          case '/production':
            return MaterialPageRoute(builder: (context) => ProductionScreen(user: user));
          case '/production/add':
            return MaterialPageRoute(builder: (context) => ProductionFormScreen(user: user));
          case '/production/edit':
            final production = args is Map<String, dynamic> ? args['production'] : null;
            return MaterialPageRoute(builder: (context) => ProductionFormScreen(user: user, production: production));
          case '/customers':
            return MaterialPageRoute(builder: (context) => CustomersScreen(user: user));
          case '/customers/add':
            return MaterialPageRoute(
              builder: (context) => CustomerFormScreen(user: user),
            );
          case '/customers/edit':
            final Customer? customer = args is Map<String, dynamic> ? args['customer'] as Customer : null;
            return MaterialPageRoute(
              builder: (context) => CustomerFormScreen(user: user, customer: customer),
            );
          case '/orders':
            return MaterialPageRoute(builder: (context) => OrdersListScreen(user: user));
          case '/orders/add':
            return MaterialPageRoute(builder: (context) => OrderFormScreen(user: user));
          case '/orders/edit':
            final order = args is Map<String, dynamic> ? args['order'] : null;
            return MaterialPageRoute(builder: (context) => OrderFormScreen(user: user, order: order));
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Not Found')),
                body: const Center(
                  child: Text('Page not found'),
                ),
              ),
            );
        }
      },
    );
  }
}
