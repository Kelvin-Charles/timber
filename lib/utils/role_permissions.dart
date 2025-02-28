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
      // Dashboard permissions
      'dashboard_view': false,
      
      // Logs permissions
      'logs_view': false,
      'logs_add': false,
      'logs_edit': false,
      'logs_delete': false,
      
      // Inventory permissions
      'inventory_view': false,
      'inventory_add': false,
      'inventory_edit': false,
      'inventory_delete': false,
      
      // Production permissions
      'production_view': false,
      'production_add': false,
      'production_edit': false,
      'production_delete': false,
      
      // Customers permissions
      'customers_view': false,
      'customers_add': false,
      'customers_edit': false,
      'customers_delete': false,
      
      // Orders permissions
      'orders_view': false,
      'orders_add': false,
      'orders_edit': false,
      'orders_delete': false,
      
      // Reports permissions
      'reports_view': false,
      'reports_generate': false,
      
      // User management permissions
      'users_view': false,
      'users_add': false,
      'users_edit': false,
      'users_delete': false,
      'manage_admins': false,
      'manage_directors': false,
      'manage_managers': false,
      'manage_workers': false,
      
      // Settings permissions
      'settings_view': false,
      'settings_edit': false,
    };
    
    // Worker permissions (basic operations only)
    if (role == 'worker') {
      permissions['dashboard_view'] = true;
      permissions['logs_view'] = true;
      permissions['inventory_view'] = true;
      permissions['production_view'] = true;
      permissions['customers_view'] = true;
      permissions['orders_view'] = true;
    }
    
    // Manager permissions (operations + worker management)
    else if (role == 'manager') {
      // All worker permissions
      permissions.forEach((key, value) {
        if (key.endsWith('_view')) {
          permissions[key] = true;
        }
      });
      
      // Add/edit permissions for operational areas
      permissions['logs_add'] = true;
      permissions['logs_edit'] = true;
      permissions['inventory_add'] = true;
      permissions['inventory_edit'] = true;
      permissions['production_add'] = true;
      permissions['production_edit'] = true;
      permissions['customers_add'] = true;
      permissions['customers_edit'] = true;
      permissions['orders_add'] = true;
      permissions['orders_edit'] = true;
      permissions['reports_generate'] = true;
      
      // User management - can only manage workers
      permissions['users_view'] = true;
      permissions['manage_workers'] = true;
    }
    
    // Director permissions (everything except user management for admins)
    else if (role == 'director') {
      // All permissions except admin management
      permissions.forEach((key, value) {
        permissions[key] = true;
      });
      
      // Cannot manage admins or other directors
      permissions['manage_admins'] = false;
      permissions['manage_directors'] = false;
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