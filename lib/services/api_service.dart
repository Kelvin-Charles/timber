import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log.dart';
import '../models/user.dart';
import '../models/inventory_item.dart';
import '../models/production.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../services/notification_service.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();
  
  // Update the baseUrl to point to your domain
  static const String baseUrl = 'https://timber.furahinisafariadevntures.agency/api';
  
  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Add auth headers to requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  // Authentication methods
  Future<User> login(String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return a mock user
    return User(
      id: 1,
      username: username,
      email: '$username@example.com',
      role: username == 'admin' ? 'admin' : (username == 'manager' ? 'manager' : 'worker'),
      fullName: username.toUpperCase(),
    );
  }
  
  Future<bool> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
  
  Future<User> register(
    String username,
    String email,
    String password,
    String role,
    String? fullName,
    String? phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'full_name': fullName,
          'phone_number': phoneNumber,
        }),
      );
      
      if (response.statusCode == 201) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Logs methods
  Future<List<Log>> getLogs() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/logs.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Log.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching logs: $e');
      // Return empty list or mock data for now
      return [];
    }
  }
  
  Future<Log> getLog(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/logs.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return Log.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Log> addLog(Log log) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logs.php'),
        headers: headers,
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Log.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add log: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding log: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Log> updateLog(Log log) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/logs.php?id=${log.id}'),
        headers: headers,
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Log.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update log: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating log: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<bool> deleteLog(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/logs.php?id=$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting log: $e');
      return false;
    }
  }
  
  // Inventory methods
  Future<List<InventoryItem>> getInventory() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock inventory items
    return List.generate(15, (index) => InventoryItem(
      id: index + 1,
      name: 'Item ${index + 1}',
      category: index % 3 == 0 ? 'Raw Material' : (index % 3 == 1 ? 'Finished Product' : 'Tool'),
      quantity: 10 + (index * 5),
      unit: index % 2 == 0 ? 'pcs' : 'kg',
      price: index % 3 == 0 ? null : (50.0 + (index * 10)),
      status: index % 4 == 0 ? 'In Stock' : (index % 4 == 1 ? 'Low Stock' : (index % 4 == 2 ? 'Out of Stock' : 'Discontinued')),
    ));
  }
  
  Future<InventoryItem> getInventoryItem(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inventory.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return InventoryItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load inventory item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<InventoryItem> addInventoryItem(InventoryItem item) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inventory.php'),
        headers: headers,
        body: json.encode(item.toJson()),
      );
      
      if (response.statusCode == 201) {
        return InventoryItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add inventory item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    try {
      final headers = await _getHeaders();
      
      // Make the API call without referencing the problematic method
      final response = await http.put(
        Uri.parse('$baseUrl/inventory.php?id=${item.id}'),
        headers: headers,
        body: json.encode(item.toJson()),
      );
      
      if (response.statusCode == 200) {
        final updatedItem = InventoryItem.fromJson(json.decode(response.body));
        return updatedItem;
      } else {
        throw Exception('Failed to update inventory item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<void> deleteInventoryItem(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/inventory.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete inventory item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Production methods
  Future<List<Production>> getProductions() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock production records
    return List.generate(8, (index) => Production(
      id: index + 1,
      productName: 'Product ${index + 1}',
      startDate: DateTime.now().subtract(Duration(days: 30 - index * 3)).toString().substring(0, 10),
      endDate: index % 3 == 0 ? null : DateTime.now().add(Duration(days: index * 5)).toString().substring(0, 10),
      status: index % 4 == 0 ? 'not_started' : (index % 4 == 1 ? 'in_progress' : (index % 4 == 2 ? 'on_hold' : 'completed')),
      currentStage: index % 3 == 0 ? 'Planning' : (index % 3 == 1 ? 'Production' : 'Quality Check'),
      completionPercentage: index * 12.5,
    ));
  }
  
  Future<Production> getProduction(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productions.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return Production.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load production: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Production> addProduction(Production production) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/productions.php'),
        headers: headers,
        body: json.encode(production.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Production.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add production: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Production> updateProduction(Production production) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/productions.php?id=${production.id}'),
        headers: headers,
        body: json.encode(production.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Production.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update production: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<void> deleteProduction(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/productions.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete production: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Customer methods
  Future<List<Customer>> getCustomers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/customers.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customers: $e');
      // Return empty list or mock data for now
      return [];
    }
  }
  
  Future<Customer> getCustomer(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/customers.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Customer> addCustomer(Customer customer) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/customers.php'),
        headers: headers,
        body: json.encode(customer.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding customer: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/customers.php?id=${customer.id}'),
        headers: headers,
        body: json.encode(customer.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating customer: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<bool> deleteCustomer(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/customers.php?id=$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting customer: $e');
      return false;
    }
  }
  
  // Order methods
  Future<List<Order>> getOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        // Print the raw response for debugging
        print('Orders API response: ${response.body}');
        
        // Safely decode the JSON
        final dynamic decodedData = json.decode(response.body);
        
        // Check if the response is a list
        if (decodedData is! List) {
          print('API did not return a list for orders: $decodedData');
          return [];
        }
        
        // Convert to List<Order>
        final List<Order> orders = [];
        for (var item in decodedData) {
          try {
            // Make sure items is a list
            if (item['items'] == null) {
              item['items'] = [];
            } else if (item['items'] is! List) {
              print('Items is not a list: ${item['items']}');
              item['items'] = [];
            }
            
            orders.add(Order.fromJson(item));
          } catch (e) {
            print('Error parsing order: $e');
            // Add a default order if parsing fails
            orders.add(Order(
              id: item['id']?.toString() ?? '0',
              customerId: 0,
              orderDate: item['order_date'] ?? DateTime.now().toString().substring(0, 10),
              status: item['status'] ?? 'unknown',
              totalAmount: 0.0,
              items: [],
            ));
          }
        }
        
        return orders;
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      // Return empty list for now
      return [];
    }
  }
  
  Future<Order> getOrder(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Order> addOrder(Order order) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders.php'),
        headers: headers,
        body: json.encode(order.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding order: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<Order> updateOrder(Order order) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders.php?id=${order.id}'),
        headers: headers,
        body: json.encode(order.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating order: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<bool> deleteOrder(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/orders.php?id=$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }
  
  Future<bool> simpleLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response: ${response.statusCode}, ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Simple login error: $e');
      return false;
    }
  }
  
  Future<List<User>> getUsers() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock users
    return List.generate(8, (index) => User(
      id: index + 1,
      username: 'user${index + 1}',
      email: 'user${index + 1}@example.com',
      role: index == 0 ? 'admin' : (index == 1 ? 'director' : (index < 4 ? 'manager' : 'worker')),
      fullName: 'User ${index + 1}',
    ));
  }
  
  Future<User?> authenticateUser(String username, String password) async {
    try {
      // For demo purposes, we'll use hardcoded credentials
      // In a real app, this would make an API call to your backend
      
      // Admin user
      if (username == 'admin' && password == 'Admin123!') {
        return User(
          id: 1,
          username: 'admin',
          email: 'admin@ngaratimber.com',
          role: 'admin',
          fullName: 'Baraka Mwenda',
        );
      }
      
      // Director user
      else if (username == 'director' && password == 'Director123!') {
        return User(
          id: 2,
          username: 'director',
          email: 'director@ngaratimber.com',
          role: 'director',
          fullName: 'Amani Ngara',
        );
      }
      
      // Manager user
      else if (username == 'manager' && password == 'Manager123!') {
        return User(
          id: 3,
          username: 'manager',
          email: 'manager@ngaratimber.com',
          role: 'manager',
          fullName: 'Grace Mollel',
        );
      }
      
      // Worker user
      else if (username == 'worker' && password == 'Worker123!') {
        return User(
          id: 4,
          username: 'worker',
          email: 'worker@ngaratimber.com',
          role: 'worker',
          fullName: 'Daniel Massawe',
        );
      }
      
      // Invalid credentials
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }
} 