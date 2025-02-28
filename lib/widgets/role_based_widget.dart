import 'package:flutter/material.dart';
import '../utils/role_permissions.dart';

class RoleBasedWidget extends StatelessWidget {
  final String userRole;
  final String requiredRole;
  final Widget child;
  final Widget? fallback;
  
  const RoleBasedWidget({
    super.key,
    required this.userRole,
    required this.requiredRole,
    required this.child,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    if (RolePermissions.hasRole(userRole, requiredRole)) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }
} 