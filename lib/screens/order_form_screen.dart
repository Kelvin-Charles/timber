import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OrderFormScreen extends StatefulWidget {
  final User? user;
  final Order? order;
  
  const OrderFormScreen({super.key, this.user, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Form controllers
  final _customerIdController = TextEditingController();
  final _orderDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paymentStatusController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<Customer> _customers = [];
  bool _isLoading = true;
  List<OrderItemWidget> _orderItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadCustomers();
    
    // If editing, populate form with existing data
    if (widget.order != null) {
      _customerIdController.text = widget.order!.customerId.toString();
      _orderDateController.text = widget.order!.orderDate;
      if (widget.order!.deliveryDate != null) {
        _deliveryDateController.text = widget.order!.deliveryDate!;
      }
      _statusController.text = widget.order!.status;
      _totalAmountController.text = widget.order!.totalAmount.toString();
      if (widget.order!.paymentStatus != null) {
        _paymentStatusController.text = widget.order!.paymentStatus!;
      }
      if (widget.order!.notes != null) {
        _notesController.text = widget.order!.notes!;
      }
      
      // Add order items
      for (var item in widget.order!.items) {
        _orderItems.add(OrderItemWidget(
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          onRemove: () => _removeOrderItem(_orderItems.length - 1),
          onChanged: _updateTotalAmount,
        ));
      }
    } else {
      // Set default values for new order
      _orderDateController.text = DateTime.now().toString().substring(0, 10);
      _statusController.text = 'pending';
      _paymentStatusController.text = 'pending';
      _totalAmountController.text = '0.00';
      
      // Add one empty order item
      _addOrderItem();
    }
  }
  
  Future<void> _loadCustomers() async {
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
  
  void _addOrderItem() {
    setState(() {
      _orderItems.add(OrderItemWidget(
        productId: 1,
        quantity: 1,
        unitPrice: 0.0,
        onRemove: () => _removeOrderItem(_orderItems.length - 1),
        onChanged: _updateTotalAmount,
      ));
    });
  }
  
  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
      _updateTotalAmount();
    });
  }
  
  void _updateTotalAmount() {
    double total = 0;
    for (var item in _orderItems) {
      total += item.quantity * item.unitPrice;
    }
    setState(() {
      _totalAmountController.text = total.toStringAsFixed(2);
    });
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order saved successfully'),
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
        title: Text(widget.order == null ? 'Add Order' : 'Edit Order'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                      ),
                      value: _customerIdController.text.isNotEmpty ? _customerIdController.text : null,
                      items: _customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.id.toString(),
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _customerIdController.text = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select customer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderDateController,
                      decoration: const InputDecoration(
                        labelText: 'Order Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _orderDateController.text = picked.toString().substring(0, 10);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter order date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Date (Optional)',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            _deliveryDateController.text = picked.toString().substring(0, 10);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                      ),
                      value: _statusController.text,
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'processing', child: Text('Processing')),
                        DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                        DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Status',
                      ),
                      value: _paymentStatusController.text,
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'partial', child: Text('Partial')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _paymentStatusController.text = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select payment status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._orderItems,
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _addOrderItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        prefixText: '\$ ',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Enter any additional notes',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(widget.order == null ? 'CREATE ORDER' : 'UPDATE ORDER'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class OrderItemWidget extends StatefulWidget {
  final int productId;
  final int quantity;
  final double unitPrice;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const OrderItemWidget({
    super.key,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  late TextEditingController _productController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  
  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.productId.toString());
    _quantityController = TextEditingController(text: widget.quantity.toString());
    _priceController = TextEditingController(text: widget.unitPrice.toString());
  }
  
  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      hintText: 'Select product',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.onChanged();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.onChanged();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 