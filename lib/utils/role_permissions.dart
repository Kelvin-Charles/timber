class RolePermissions {
  // Role hierarchy (higher index means more permissions)
  static const List<String> _roleHierarchy = ['worker', 'manager', 'admin', 'director'];
  
  // Check if a user has a specific role
  static bool hasRole(String userRole, String requiredRole) {
    if (!_roleHierarchy.contains(userRole) || !_roleHierarchy.contains(requiredRole)) {
      return false;
    }
    
    int userRoleIndex = _roleHierarchy.indexOf(userRole);
    int requiredRoleIndex = _roleHierarchy.indexOf(requiredRole);
    
    return userRoleIndex >= requiredRoleIndex;
  }
  
  // Get permissions for each role
  static Map<String, bool> getPermissions(String role) {
    // Default permissions (all false)
    Map<String, bool> permissions = {
      // Inventory permissions
      'inventory_view': false,
      'inventory_add': false,
      'inventory_edit': false,
      'inventory_delete': false,
      
      // Log tracking permissions
      'logs_view': false,
      'logs_add': false,
      'logs_edit': false,
      'logs_delete': false,
      
      // Production permissions
      'production_view': false,
      'production_add': false,
      'production_edit': false,
      'production_delete': false,
      
      // Customer permissions
      'customers_view': false,
      'customers_add': false,
      'customers_edit': false,
      'customers_delete': false,
      
      // Order permissions
      'orders_view': false,
      'orders_add': false,
      'orders_edit': false,
      'orders_delete': false,
      
      // User management permissions
      'users_view': false,
      'users_add': false,
      'users_edit': false,
      'users_delete': false,
      
      // Reports permissions
      'reports_view': false,
      'reports_export': false,
      
      // Settings permissions
      'settings_view': false,
      'settings_edit': false,
    };
    
    // Worker permissions
    if (hasRole(role, 'worker')) {
      permissions['inventory_view'] = true;
      permissions['logs_view'] = true;
      permissions['production_view'] = true;
      permissions['customers_view'] = true;
      permissions['orders_view'] = true;
    }
    
    // Manager permissions
    if (hasRole(role, 'manager')) {
      // All worker permissions plus:
      permissions['inventory_add'] = true;
      permissions['inventory_edit'] = true;
      permissions['logs_add'] = true;
      permissions['logs_edit'] = true;
      permissions['production_add'] = true;
      permissions['production_edit'] = true;
      permissions['customers_add'] = true;
      permissions['customers_edit'] = true;
      permissions['orders_add'] = true;
      permissions['orders_edit'] = true;
      permissions['reports_view'] = true;
      permissions['reports_export'] = true;
    }
    
    // Admin permissions
    if (hasRole(role, 'admin')) {
      // All manager permissions plus:
      permissions['inventory_delete'] = true;
      permissions['logs_delete'] = true;
      permissions['production_delete'] = true;
      permissions['customers_delete'] = true;
      permissions['orders_delete'] = true;
      permissions['users_view'] = true;
      permissions['users_add'] = true;
      permissions['users_edit'] = true;
      permissions['settings_view'] = true;
      permissions['settings_edit'] = true;
    }
    
    // Director permissions
    if (hasRole(role, 'director')) {
      // All admin permissions plus:
      permissions['users_delete'] = true;
      // Any additional director-specific permissions
    }
    
    return permissions;
  }
} 