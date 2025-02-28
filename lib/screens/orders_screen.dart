import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../utils/role_permissions.dart';
import '../widgets/role_based_action_button.dart';

class OrdersScreen extends StatefulWidget {
  final User? user;
  
  const OrdersScreen({super.key, this.user});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _apiService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addOrder() {
    Navigator.pushNamed(context, '/orders/add', arguments: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    _buildStatusChip(order.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Customer ID: ${order.customerId}'),
                                Text('Date: ${order.orderDate}'),
                                Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                                if (order.deliveryDate != null)
                                  Text('Delivery: ${order.deliveryDate}'),
                                if (order.paymentStatus != null)
                                  Text('Payment: ${order.paymentStatus}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Items: ${order.items.length}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'orders_add',
        onPressed: _addOrder,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
} 