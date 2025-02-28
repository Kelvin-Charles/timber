import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../models/inventory_item.dart';
import '../services/api_service.dart';
import '../utils/role_permissions.dart';
import '../widgets/role_based_action_button.dart';

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
                            title: Text(item.name),
                            subtitle: Text('${item.quantity} ${item.unit} - ${item.status}'),
                            trailing: Text(
                              item.price != null ? 'TSh ${item.price!.toStringAsFixed(2)}' : 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              // Navigate to item details
                            },
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