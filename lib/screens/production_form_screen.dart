import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/production.dart';
import '../theme/app_theme.dart';

class ProductionFormScreen extends StatefulWidget {
  final User? user;
  final Production? production;
  
  const ProductionFormScreen({super.key, this.user, this.production});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _productNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _currentStageController = TextEditingController();
  final _completionPercentageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.production != null) {
      _productNameController.text = widget.production!.productName;
      _startDateController.text = widget.production!.startDate;
      if (widget.production!.endDate != null) {
        _endDateController.text = widget.production!.endDate!;
      }
      _statusController.text = widget.production!.status;
      _currentStageController.text = widget.production!.currentStage;
      _completionPercentageController.text = widget.production!.completionPercentage.toString();
    } else {
      // Set default values for new production
      _startDateController.text = DateTime.now().toString().substring(0, 10);
      _statusController.text = 'not_started';
      _currentStageController.text = 'Planning';
      _completionPercentageController.text = '0';
    }
  }
  
  @override
  void dispose() {
    _productNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    _currentStageController.dispose();
    _completionPercentageController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Production saved successfully'),
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
        title: Text(widget.production == null ? 'Add Production' : 'Edit Production'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDateController.text = picked.toString().substring(0, 10);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (Optional)',
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
                      _endDateController.text = picked.toString().substring(0, 10);
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
                  DropdownMenuItem(value: 'not_started', child: Text('Not Started')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
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
                  labelText: 'Current Stage',
                ),
                value: _currentStageController.text,
                items: const [
                  DropdownMenuItem(value: 'Planning', child: Text('Planning')),
                  DropdownMenuItem(value: 'Production', child: Text('Production')),
                  DropdownMenuItem(value: 'Quality Check', child: Text('Quality Check')),
                  DropdownMenuItem(value: 'Packaging', child: Text('Packaging')),
                  DropdownMenuItem(value: 'Shipping', child: Text('Shipping')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentStageController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select current stage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _completionPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Completion Percentage',
                  hintText: 'Enter completion percentage (0-100)',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter completion percentage';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null) {
                    return 'Please enter a valid number';
                  }
                  if (percentage < 0 || percentage > 100) {
                    return 'Percentage must be between 0 and 100';
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
                child: Text(widget.production == null ? 'ADD PRODUCTION' : 'UPDATE PRODUCTION'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 