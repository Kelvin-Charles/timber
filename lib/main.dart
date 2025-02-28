import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/log.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/logs_screen.dart';
import 'models/user.dart';
import 'dart:io';
import 'widgets/notification_bell.dart';
import 'services/notification_service.dart';
import 'screens/orders_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/users_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/log_form_screen.dart';
import 'screens/inventory_form_screen.dart';
import 'screens/production_form_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug mode
  const bool debugMode = true;
  
  if (debugMode) {
    print('Running in debug mode');
    // Print additional diagnostic information
  }
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  
  // For development only - bypass SSL certificate verification
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(const NgaraTimberApp());
}

// Custom HTTP overrides for development
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class NgaraTimberApp extends StatefulWidget {
  const NgaraTimberApp({super.key});

  @override
  State<NgaraTimberApp> createState() => _NgaraTimberAppState();
}

class _NgaraTimberAppState extends State<NgaraTimberApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ngara Timber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        // Extract the user argument from settings
        final args = settings.arguments;
        final User? user = args is User ? args : null;
        
        // Handle all routes with user parameter
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => DashboardScreen(user: user));
          case '/logs':
            return MaterialPageRoute(builder: (context) => LogsScreen(user: user));
          case '/logs/add':
            return MaterialPageRoute(builder: (context) => LogFormScreen(user: user));
          case '/logs/edit':
            final Log? log = args is Map<String, dynamic> ? args['log'] as Log : null;
            return MaterialPageRoute(builder: (context) => LogFormScreen(user: user, log: log));
          case '/inventory':
            return MaterialPageRoute(builder: (context) => InventoryScreen(user: user));
          case '/inventory/add':
            return MaterialPageRoute(builder: (context) => InventoryFormScreen(user: user));
          case '/production':
            return MaterialPageRoute(builder: (context) => ProductionScreen(user: user));
          case '/production/add':
            return MaterialPageRoute(builder: (context) => ProductionFormScreen(user: user));
          case '/customers':
            return MaterialPageRoute(builder: (context) => CustomersScreen(user: user));
          case '/customers/add':
            return MaterialPageRoute(builder: (context) => CustomerFormScreen(user: user));
          case '/orders':
            return MaterialPageRoute(builder: (context) => OrdersScreen(user: user));
          case '/orders/add':
            return MaterialPageRoute(builder: (context) => OrderFormScreen(user: user));
          case '/reports':
            return MaterialPageRoute(builder: (context) => ReportsScreen(user: user));
          case '/users':
            return MaterialPageRoute(builder: (context) => UsersScreen(user: user));
          case '/settings':
            return MaterialPageRoute(builder: (context) => SettingsScreen(user: user));
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Not Found')),
                body: Center(child: Text('Route ${settings.name} not found')),
              ),
            );
        }
      },
    );
  }
}

// Placeholder screens for other sections
class InventoryScreen extends StatelessWidget {
  final User? user;
  
  const InventoryScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: const Center(
        child: Text('Inventory Management Screen - Coming Soon'),
      ),
    );
  }
}

class ProductionScreen extends StatelessWidget {
  final User? user;
  
  const ProductionScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Production')),
      body: const Center(
        child: Text('Production Management Screen - Coming Soon'),
      ),
    );
  }
}

class CustomersScreen extends StatelessWidget {
  final User? user;
  
  const CustomersScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: const Center(
        child: Text('Customer Management Screen - Coming Soon'),
      ),
    );
  }
}
