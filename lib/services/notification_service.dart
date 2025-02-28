import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';

class NotificationService {
  static const String _storageKey = 'app_notifications';
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();
  
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  
  List<AppNotification> _notifications = [];
  
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  // Initialize the service
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_storageKey);
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications = decoded
            .map((item) => AppNotification.fromJson(item))
            .toList();
      } else {
        _notifications = [];
        // Create sample notifications if none exist
        await createSampleNotifications();
      }
      
      // Notify listeners
      _notificationsController.add(_notifications);
      
      print('Loaded ${_notifications.length} notifications');
    } catch (e) {
      print('Error initializing notifications: $e');
      _notifications = [];
    }
  }
  
  // Load notifications from storage
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_storageKey);
    
    if (notificationsJson != null) {
      final List<dynamic> decoded = json.decode(notificationsJson);
      _notifications = decoded
          .map((item) => AppNotification.fromJson(item))
          .toList();
      
      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _notificationsController.add(_notifications);
    }
  }
  
  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_storageKey, notificationsJson);
      print('Saved ${_notifications.length} notifications');
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }
  
  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification); // Add to beginning of list
    _notificationsController.add(_notifications);
    await _saveNotifications();
  }
  
  // Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
      await _saveNotifications();
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Simulate API call to mark all notifications as read
    await Future.delayed(const Duration(milliseconds: 500));
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationsController.add(_notifications);
    await _saveNotifications();
  }
  
  // Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
    await _saveNotifications();
  }
  
  // Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _notificationsController.add(_notifications);
    await _saveNotifications();
  }
  
  // Get unread count
  Future<int> getUnreadCount() async {
    // Simulate API call to get unread notifications count
    await Future.delayed(const Duration(milliseconds: 300));
    return _notifications.where((n) => !n.isRead).length;
  }
  
  // Get all notifications
  List<AppNotification> get notifications => _notifications;
  
  // Create a stock update notification
  Future<void> createStockUpdateNotification({
    required String itemName,
    required int oldQuantity,
    required int newQuantity,
    required String unit,
    String? location,
  }) async {
    final String action = newQuantity > oldQuantity ? 'increased' : 'decreased';
    final int difference = (newQuantity - oldQuantity).abs();
    
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Stock Update',
      message: '$itemName stock has $action by $difference $unit${difference > 1 ? 's' : ''}${location != null ? ' in $location' : ''}.',
      timestamp: DateTime.now(),
      type: NotificationType.stockUpdate,
      additionalData: {
        'item_name': itemName,
        'old_quantity': oldQuantity,
        'new_quantity': newQuantity,
        'unit': unit,
        'location': location,
      },
    );
    
    await addNotification(notification);
  }
  
  // Create sample notifications
  Future<void> createSampleNotifications() async {
    // Clear existing notifications
    await clearAll();
    
    // Add sample notifications
    await addNotification(
      AppNotification(
        id: 1,
        title: 'New Log Added',
        message: 'A new log has been added to the inventory.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.stockUpdate,
        isRead: false,
      ),
    );
    
    await addNotification(
      AppNotification(
        id: 2,
        title: 'Order Status Update',
        message: 'Order #1234 has been marked as delivered.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.orderStatus,
        isRead: true,
      ),
    );
    
    await addNotification(
      AppNotification(
        id: 3,
        title: 'Production Complete',
        message: 'Production of Mahogany Planks has been completed.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.productionUpdate,
        isRead: false,
      ),
    );
    
    await addNotification(
      AppNotification(
        id: 4,
        title: 'System Maintenance',
        message: 'The system will be down for maintenance on Sunday from 2-4 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.systemAlert,
        isRead: false,
      ),
    );
  }
  
  // Dispose the service
  void dispose() {
    _notificationsController.close();
  }
} 