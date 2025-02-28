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
    await _loadNotifications();
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
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
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
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
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
  
  // Dispose the service
  void dispose() {
    _notificationsController.close();
  }
} 