import 'package:flutter/material.dart';
import '../utils/role_permissions.dart';

class RoleBasedActionButton extends StatelessWidget {
  final String userRole;
  final String requiredPermission;
  final VoidCallback onPressed;
  final Widget child;
  
  const RoleBasedActionButton({
    super.key,
    required this.userRole,
    required this.requiredPermission,
    required this.onPressed,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    final permissions = RolePermissions.getPermissions(userRole);
    
    if (permissions[requiredPermission] == true) {
      return FloatingActionButton(
        onPressed: onPressed,
        child: child,
      );
    } else {
      return const SizedBox.shrink(); // Hide button if user doesn't have permission
    }
  }
} 