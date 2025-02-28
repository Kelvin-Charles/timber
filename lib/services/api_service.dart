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
  
  // User Authentication
  Future<User> login(String username, String password) async {
    try {
      print('Attempting login for user: $username');
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Save token to shared preferences
        if (userData['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', userData['token']);
        }
        
        // Check if all required fields are present
        if (userData['username'] == null || userData['email'] == null || userData['role'] == null) {
          throw Exception('Invalid user data received from server');
        }
        
        return User.fromJson(userData);
      } else {
        throw Exception('Login failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains("type 'String' is not a subtype of type 'int?'")) {
        print('Type conversion error detected. Check the User.fromJson method.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
  
  // Log Management
  Future<List<Log>> getLogs() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/logs.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Log.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
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
  
  // Inventory Management
  Future<List<InventoryItem>> getInventory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inventory.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
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
  
  // Production Management
  Future<List<Production>> getProductions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productions.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Production.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load productions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
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
  
  // Customer Management
  Future<List<Customer>> getCustomers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/customers.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
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
  
  // Order Management
  Future<List<Order>> getOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
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
} 