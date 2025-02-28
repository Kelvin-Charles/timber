import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../utils/role_permissions.dart';
import '../services/api_service.dart';
import '../widgets/role_based_action_button.dart';

class UsersScreen extends StatefulWidget {
  final User? user;
  
  const UsersScreen({super.key, this.user});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _apiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addUser() {
    // Navigate to add user screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUsers,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                              child: Text(
                                user.username.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: _getRoleColor(user.role),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(user.fullName ?? user.username),
                            subtitle: Text('${user.email} • ${user.role.toUpperCase()}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Edit user
                              },
                            ),
                            onTap: () {
                              // View user details
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        userRole: widget.user?.role ?? 'worker',
        requiredPermission: 'users_add',
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.blue;
      case 'worker':
        return Colors.green;
      case 'director':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 