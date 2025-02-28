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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    
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

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      case 'pending':
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

  void _viewOrderDetails(Order order) {
    // Simple order details view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${order.orderDate}'),
            Text('Status: ${order.status}'),
            Text('Total: TSh ${order.totalAmount.toStringAsFixed(2)}'),
            if (order.paymentStatus != null)
              Text('Payment: ${order.paymentStatus}'),
            if (order.deliveryDate != null)
              Text('Delivery: ${order.deliveryDate}'),
            const SizedBox(height: 10),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((item) => 
              Text('• Product #${item.productId}: ${item.quantity} x TSh ${item.unitPrice.toStringAsFixed(2)}')
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
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
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                              child: Icon(
                                Icons.shopping_cart,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                            title: Text('Order #${order.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${order.orderDate}'),
                                Row(
                                  children: [
                                    _buildStatusChip(order.status),
                                    const SizedBox(width: 8),
                                    if (order.paymentStatus != null)
                                      _buildPaymentStatusChip(order.paymentStatus!),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(
                              'TSh ${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () => _viewOrderDetails(order),
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
} 