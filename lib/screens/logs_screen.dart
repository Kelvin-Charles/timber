import 'package:flutter/material.dart';
import '../models/log.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/log_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/role_based_action_button.dart';
import '../utils/role_permissions.dart';

class LogsScreen extends StatefulWidget {
  final User? user;
  
  const LogsScreen({super.key, this.user});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final ApiService _apiService = ApiService();
  List<Log> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _apiService.getLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addLog() {
    Navigator.pushNamed(context, '/logs/add');
  }

  void _editLog(Log log) {
    // Navigate to edit log screen
  }

  Future<void> _deleteLog(int id) async {
    // Delete log logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadLogs,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
                  ? const Center(child: Text('No logs found'))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return LogCard(
                          log: log,
                          onEdit: RolePermissions.getPermissions(widget.user?.role ?? 'worker')['logs_edit'] == true
                              ? () => _editLog(log)
                              : null,
                          onDelete: RolePermissions.getPermissions(widget.user?.role ?? 'worker')['logs_delete'] == true
                              ? () => _deleteLog(log.id!)
                              : null,
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'logs_add',
        onPressed: _addLog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 