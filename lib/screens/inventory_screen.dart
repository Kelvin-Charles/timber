import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../models/inventory_item.dart';
import '../services/api_service.dart';
import '../utils/role_permissions.dart';
import '../widgets/role_based_action_button.dart';
import '../screens/inventory_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  final User? user;
  
  const InventoryScreen({super.key, this.user});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _apiService = ApiService();
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;

  // Define the helper methods as static to ensure they're accessible
  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'raw materials':
        return Colors.green;
      case 'finished products':
        return Colors.blue;
      case 'tools':
        return Colors.orange;
      case 'supplies':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'raw materials':
        return Icons.forest;
      case 'finished products':
        return Icons.inventory;
      case 'tools':
        return Icons.handyman;
      case 'supplies':
        return Icons.category;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _apiService.getInventory();
      setState(() {
        _inventoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addInventoryItem() {
    Navigator.pushNamed(context, '/inventory/add', arguments: widget.user);
  }

  void _viewItemDetails(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryItemScreen(
          item: item,
          user: widget.user,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the inventory list if item was updated
        _loadInventory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInventory,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _inventoryItems.isEmpty
                  ? const Center(child: Text('No inventory items found'))
                  : ListView.builder(
                      itemCount: _inventoryItems.length,
                      itemBuilder: (context, index) {
                        final item = _inventoryItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(item.category).withOpacity(0.2),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: _getCategoryColor(item.category),
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text('${item.quantity} ${item.unit} • ${item.category}'),
                            trailing: item.price != null
                                ? Text(
                                    'TSh ${item.price!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                            onTap: () => _viewItemDetails(item),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'inventory_add',
        onPressed: _addInventoryItem,
        child: const Icon(Icons.add),
      ),
    );
  }
} 