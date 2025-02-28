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
    // Show a dialog to select the role for the new user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.user?.role == 'admin')
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor('admin').withOpacity(0.2),
                  child: Icon(Icons.admin_panel_settings, color: _getRoleColor('admin')),
                ),
                title: const Text('Admin'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddUserScreen('admin');
                },
              ),
            if (widget.user?.role == 'admin')
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor('director').withOpacity(0.2),
                  child: Icon(Icons.business, color: _getRoleColor('director')),
                ),
                title: const Text('Director'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddUserScreen('director');
                },
              ),
            if (widget.user?.role == 'admin' || widget.user?.role == 'director')
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor('manager').withOpacity(0.2),
                  child: Icon(Icons.manage_accounts, color: _getRoleColor('manager')),
                ),
                title: const Text('Manager'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddUserScreen('manager');
                },
              ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor('worker').withOpacity(0.2),
                child: Icon(Icons.person, color: _getRoleColor('worker')),
              ),
              title: const Text('Worker'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddUserScreen('worker');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddUserScreen(String role) {
    Navigator.pushNamed(
      context,
      '/users/add',
      arguments: {'user': widget.user, 'role': role},
    );
  }

  bool _canManageUser(String targetUserRole) {
    final userRole = widget.user?.role ?? 'worker';
    
    if (userRole == 'admin') {
      // Admin can manage all users
      return true;
    } else if (userRole == 'director') {
      // Director can manage managers and workers, but not admins or other directors
      return targetUserRole == 'manager' || targetUserRole == 'worker';
    } else if (userRole == 'manager') {
      // Manager can only manage workers
      return targetUserRole == 'worker';
    }
    
    // Workers can't manage anyone
    return false;
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
                        final canManage = _canManageUser(user.role);
                        
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
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _getRoleColor(user.role)),
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getRoleColor(user.role),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(user.email),
                              ],
                            ),
                            trailing: canManage
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editUser(user),
                                        tooltip: 'Edit User',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteUser(user.id),
                                        tooltip: 'Delete User',
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () => _viewUserDetails(user),
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

  void _editUser(User user) {
    // Implement edit user functionality
  }

  void _deleteUser(String userId) {
    // Implement delete user functionality
  }

  void _viewUserDetails(User user) {
    final canManage = _canManageUser(user.role);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // User header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? user.username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _getRoleColor(user.role)),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getRoleColor(user.role),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 30),
                    
                    // User details
                    _buildDetailItem(Icons.person, 'Username', user.username),
                    _buildDetailItem(Icons.email, 'Email', user.email),
                    if (user.phoneNumber != null)
                      _buildDetailItem(Icons.phone, 'Phone', user.phoneNumber!),
                    
                    const SizedBox(height: 30),
                    
                    // Action buttons
                    if (canManage)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _editUser(user);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteUser(user.id);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Text(label),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
} 