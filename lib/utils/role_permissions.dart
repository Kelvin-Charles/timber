class RolePermissions {
  // Role hierarchy (higher index means more permissions)
  static const List<String> _roleHierarchy = ['worker', 'manager', 'admin', 'director'];
  
  // Check if a user has a specific role
  static bool hasRole(String userRole, String requiredRole) {
    if (userRole == requiredRole) return true;
    
    // Admin has all permissions
    if (userRole == 'admin') return true;
    
    // Director has most permissions except admin-specific ones
    if (userRole == 'director' && requiredRole != 'admin') return true;
    
    // Manager has permissions for operations but not for admin/director functions
    if (userRole == 'manager' && 
        (requiredRole != 'admin' && requiredRole != 'director')) return true;
    
    return false;
  }
  
  // Get permissions for each role
  static Map<String, bool> getPermissions(String role) {
    final Map<String, bool> permissions = {
      // View permissions
      'logs_view': true,
      'inventory_view': true,
      'production_view': true,
      'customers_view': true,
      'orders_view': true,
      'reports_view': false,
      'users_view': false,
      'settings_view': false,
      
      // Add permissions
      'logs_add': false,
      'inventory_add': false,
      'production_add': false,
      'customers_add': false,
      'orders_add': false,
      'users_add': false,
      
      // Edit permissions
      'logs_edit': false,
      'inventory_edit': false,
      'production_edit': false,
      'customers_edit': false,
      'orders_edit': false,
      'users_edit': false,
      
      // Delete permissions
      'logs_delete': false,
      'inventory_delete': false,
      'production_delete': false,
      'customers_delete': false,
      'orders_delete': false,
      'users_delete': false,
    };
    
    // Worker permissions (basic view only)
    if (role == 'worker') {
      // Workers already have basic view permissions
      permissions['logs_add'] = true;
      permissions['production_edit'] = true;
    }
    
    // Manager permissions (operations)
    else if (role == 'manager') {
      // Add permissions
      permissions['logs_add'] = true;
      permissions['inventory_add'] = true;
      permissions['production_add'] = true;
      permissions['customers_add'] = true;
      permissions['orders_add'] = true;
      
      // Edit permissions
      permissions['logs_edit'] = true;
      permissions['inventory_edit'] = true;
      permissions['production_edit'] = true;
      permissions['customers_edit'] = true;
      permissions['orders_edit'] = true;
      
      // Delete permissions
      permissions['logs_delete'] = true;
      permissions['inventory_delete'] = true;
      permissions['production_delete'] = true;
      
      // View permissions
      permissions['reports_view'] = true;
    }
    
    // Director permissions (everything except user management)
    else if (role == 'director') {
      // All permissions except user management
      permissions.forEach((key, value) {
        permissions[key] = true;
      });
      
      // Restrict user management
      permissions['users_add'] = false;
      permissions['users_edit'] = false;
      permissions['users_delete'] = false;
    }
    
    // Admin permissions (everything)
    else if (role == 'admin') {
      permissions.forEach((key, value) {
        permissions[key] = true;
      });
    }
    
    return permissions;
  }
} 