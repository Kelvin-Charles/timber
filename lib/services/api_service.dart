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
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock logs
    return List.generate(10, (index) => Log(
      id: index + 1,
      logNumber: 'LOG${1000 + index}',
      species: index % 2 == 0 ? 'Pine' : 'Cedar',
      diameter: 30 + (index * 2),
      length: 4 + (index % 3),
      quality: index % 3 == 0 ? 'A' : (index % 3 == 1 ? 'B' : 'C'),
      source: 'Supplier ${index % 5 + 1}',
      receivedDate: DateTime.now().subtract(Duration(days: index * 3)).toString().substring(0, 10),
      status: index % 4 == 0 ? 'Available' : (index % 4 == 1 ? 'In Production' : (index % 4 == 2 ? 'Sold' : 'Damaged')),
      notes: index % 3 == 0 ? 'Good quality log' : null,
    ));
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
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<void> deleteLog(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/logs.php?id=$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
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
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock customers
    return List.generate(12, (index) => Customer(
      id: index + 1,
      name: 'Customer ${index + 1}',
      email: 'customer${index + 1}@example.com',
      phone: '+254 7${index}${index} ${index}00 ${index}00',
      address: 'Address ${index + 1}',
      totalOrders: index + 1,
      totalSpent: (index + 1) * 1000.0,
    ));
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
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Order methods
  Future<List<Order>> getOrders() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock orders
    return List.generate(10, (index) => Order(
      id: 'ORD-${1000 + index}',
      customerId: index % 5 + 1,
      orderDate: DateTime.now().subtract(Duration(days: index * 3)).toString().substring(0, 10),
      deliveryDate: index % 3 == 0 ? null : DateTime.now().add(Duration(days: 7 + index)).toString().substring(0, 10),
      status: index % 5 == 0 ? 'Pending' : (index % 5 == 1 ? 'Processing' : (index % 5 == 2 ? 'Shipped' : (index % 5 == 3 ? 'Delivered' : 'Cancelled'))),
      totalAmount: 500.0 + (index * 250),
      paymentStatus: index % 3 == 0 ? 'Pending' : (index % 3 == 1 ? 'Partial' : 'Paid'),
      items: List.generate(index % 3 + 1, (i) => OrderItem(
        productId: i + 1,
        quantity: i + 1,
        unitPrice: 100.0 + (i * 50),
      )),
    ));
  }
  
  Future<Order> getOrder(int id) async {
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
      throw Exception('Failed to connect to server: $e');
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
} 