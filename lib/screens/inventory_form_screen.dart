import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/inventory_item.dart';
import '../theme/app_theme.dart';

class InventoryFormScreen extends StatefulWidget {
  final User? user;
  final InventoryItem? item;
  
  const InventoryFormScreen({super.key, this.user, this.item});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _statusController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _categoryController.text = widget.item!.category;
      _quantityController.text = widget.item!.quantity.toString();
      _unitController.text = widget.item!.unit;
      if (widget.item!.price != null) {
        _priceController.text = widget.item!.price.toString();
      }
      _statusController.text = widget.item!.status;
    } else {
      // Set default values for new item
      _statusController.text = 'In Stock';
      _categoryController.text = 'Raw Material';
      _unitController.text = 'pcs';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _statusController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory item saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter item name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                value: _categoryController.text,
                items: const [
                  DropdownMenuItem(value: 'Raw Material', child: Text('Raw Material')),
                  DropdownMenuItem(value: 'Finished Product', child: Text('Finished Product')),
                  DropdownMenuItem(value: 'Tool', child: Text('Tool')),
                ],
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      value: _unitController.text,
                      items: const [
                        DropdownMenuItem(value: 'pcs', child: Text('Pieces')),
                        DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                        DropdownMenuItem(value: 'm', child: Text('Meters')),
                        DropdownMenuItem(value: 'm²', child: Text('Square Meters')),
                        DropdownMenuItem(value: 'm³', child: Text('Cubic Meters')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _unitController.text = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Optional)',
                  hintText: 'Enter price per unit',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
                value: _statusController.text,
                items: const [
                  DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                  DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                  DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                  DropdownMenuItem(value: 'Discontinued', child: Text('Discontinued')),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.item == null ? 'ADD ITEM' : 'UPDATE ITEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 