import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../widgets/app_drawer.dart';
import '../widgets/role_based_action_button.dart';

class OrdersListScreen extends StatefulWidget {
  final User? user;
  
  const OrdersListScreen({super.key, this.user});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  bool _isLoading = false;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    setState(() {
      _isLoading = true;
    });
    
    // Create mock orders
    _orders = List.generate(10, (index) => Order(
      id: 'ORD-${1000 + index}',
      customerId: index % 5 + 1,
      orderDate: DateTime.now().subtract(Duration(days: index * 3)).toString().substring(0, 10),
      deliveryDate: index % 3 == 0 ? null : DateTime.now().add(Duration(days: 7 + index)).toString().substring(0, 10),
      status: index % 5 == 0 ? 'Pending' : (index % 5 == 1 ? 'Processing' : (index % 5 == 2 ? 'Shipped' : (index % 5 == 3 ? 'Delivered' : 'Cancelled'))),
      totalAmount: 500.0 + (index * 250),
      paymentStatus: index % 3 == 0 ? 'Pending' : (index % 3 == 1 ? 'Partial' : 'Paid'),
      notes: 'Order notes ${index + 1}',
      items: List.generate(index % 3 + 1, (i) => OrderItem(
        productId: i + 1,
        quantity: i + 1,
        unitPrice: 100.0 + (i * 50),
      )),
    ));
    
    setState(() {
      _isLoading = false;
    });
  }

  void _addOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add order functionality will be implemented soon')),
    );
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
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'orders_add',
        onPressed: _addOrder,
        child: const Icon(Icons.add),
      ),
    );
  }
} 