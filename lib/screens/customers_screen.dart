import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../utils/role_permissions.dart';
import '../widgets/role_based_action_button.dart';

class CustomersScreen extends StatefulWidget {
  final User? user;
  
  const CustomersScreen({super.key, this.user});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _apiService.getCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addCustomer() {
    Navigator.pushNamed(context, '/customers/add', arguments: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCustomers,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _customers.isEmpty
                  ? const Center(child: Text('No customers found'))
                  : ListView.builder(
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                customer.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(customer.name),
                            subtitle: Text(customer.email),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${customer.totalOrders} orders',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (customer.totalSpent != null)
                                  Text(
                                    '\$${customer.totalSpent!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to customer details
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'customers_add',
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
} 