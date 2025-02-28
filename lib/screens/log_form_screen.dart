import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class LogFormScreen extends StatefulWidget {
  final User? user;
  final Log? log; // For editing existing log
  
  const LogFormScreen({super.key, this.user, this.log});

  @override
  State<LogFormScreen> createState() => _LogFormScreenState();
}

class _LogFormScreenState extends State<LogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _logNumberController = TextEditingController();
  final _speciesController = TextEditingController();
  final _diameterController = TextEditingController();
  final _lengthController = TextEditingController();
  final _qualityController = TextEditingController();
  final _sourceController = TextEditingController();
  final _receivedDateController = TextEditingController();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.log != null) {
      _logNumberController.text = widget.log!.logNumber;
      _speciesController.text = widget.log!.species;
      _diameterController.text = widget.log!.diameter.toString();
      _lengthController.text = widget.log!.length.toString();
      _qualityController.text = widget.log!.quality;
      _sourceController.text = widget.log!.source;
      _receivedDateController.text = widget.log!.receivedDate;
      _statusController.text = widget.log!.status;
      if (widget.log!.notes != null) {
        _notesController.text = widget.log!.notes!;
      }
    } else {
      // Set default values for new log
      _receivedDateController.text = DateTime.now().toString().substring(0, 10);
      _statusController.text = 'Available';
    }
  }
  
  @override
  void dispose() {
    _logNumberController.dispose();
    _speciesController.dispose();
    _diameterController.dispose();
    _lengthController.dispose();
    _qualityController.dispose();
    _sourceController.dispose();
    _receivedDateController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a Log object from form data
        final log = Log(
          id: widget.log?.id ?? "",
          logNumber: _logNumberController.text,
          species: _speciesController.text,
          diameter: double.parse(_diameterController.text),
          length: double.parse(_lengthController.text),
          quality: _qualityController.text,
          source: _sourceController.text,
          status: _statusController.text,
          receivedDate: _receivedDateController.text,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        // Save the log using the API service
        final apiService = ApiService();
        await apiService.addLog(log);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate back to logs screen
          Navigator.pop(context);
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving log: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log == null ? 'Add New Log' : 'Edit Log'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _logNumberController,
                decoration: const InputDecoration(
                  labelText: 'Log Number',
                  hintText: 'Enter log number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter log number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  hintText: 'Enter log species',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter species';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diameterController,
                      decoration: const InputDecoration(
                        labelText: 'Diameter (cm)',
                        hintText: 'Enter diameter',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter diameter';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(
                        labelText: 'Length (m)',
                        hintText: 'Enter length',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter length';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualityController,
                decoration: const InputDecoration(
                  labelText: 'Quality',
                  hintText: 'Enter log quality (A, B, C)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quality';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  hintText: 'Enter log source',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter source';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receivedDateController,
                decoration: const InputDecoration(
                  labelText: 'Received Date',
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
                      _receivedDateController.text = picked.toString().substring(0, 10);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter received date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
                value: _statusController.text,
                items: const [
                  DropdownMenuItem(value: 'Available', child: Text('Available')),
                  DropdownMenuItem(value: 'In Production', child: Text('In Production')),
                  DropdownMenuItem(value: 'Sold', child: Text('Sold')),
                  DropdownMenuItem(value: 'Damaged', child: Text('Damaged')),
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
                child: Text(widget.log == null ? 'ADD LOG' : 'UPDATE LOG'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 