import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../models/production.dart';
import '../services/api_service.dart';
import '../utils/role_permissions.dart';
import '../widgets/role_based_action_button.dart';
import '../theme/app_theme.dart';

class ProductionScreen extends StatefulWidget {
  final User? user;
  
  const ProductionScreen({super.key, this.user});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final ApiService _apiService = ApiService();
  List<Production> _productions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductions();
  }

  Future<void> _loadProductions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productions = await _apiService.getProductions();
      setState(() {
        _productions = productions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addProduction() {
    Navigator.pushNamed(context, '/production/add', arguments: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProductions,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _productions.isEmpty
                  ? const Center(child: Text('No production records found'))
                  : ListView.builder(
                      itemCount: _productions.length,
                      itemBuilder: (context, index) {
                        final production = _productions[index];
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
                                      production.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    _buildStatusChip(production.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Stage: ${production.currentStage}'),
                                Text('Started: ${production.startDate}'),
                                if (production.endDate != null)
                                  Text('Completed: ${production.endDate}'),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: production.completionPercentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.secondaryColor,
                                  ),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${production.completionPercentage.toInt()}% Complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
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
        requiredPermission: 'production_add',
        onPressed: _addProduction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'not_started':
        color = Colors.grey;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'on_hold':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.replaceAll('_', ' '),
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