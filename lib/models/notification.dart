import 'package:flutter/material.dart';

enum NotificationType {
  stockUpdate,
  orderStatus,
  productionUpdate,
  systemAlert,
  general
}

class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionLink;
  final Map<String, dynamic>? additionalData;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionLink,
    this.additionalData,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      isRead: json['is_read'] ?? false,
      actionLink: json['action_link'],
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'action_link': actionLink,
      'additional_data': additionalData,
    };
  }

  // Get icon based on notification type
  IconData get icon {
    switch (type) {
      case NotificationType.stockUpdate:
        return Icons.inventory;
      case NotificationType.orderStatus:
        return Icons.shopping_cart;
      case NotificationType.productionUpdate:
        return Icons.precision_manufacturing;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  // Get color based on notification type
  Color get color {
    switch (type) {
      case NotificationType.stockUpdate:
        return Colors.blue;
      case NotificationType.orderStatus:
        return Colors.green;
      case NotificationType.productionUpdate:
        return Colors.orange;
      case NotificationType.systemAlert:
        return Colors.red;
      case NotificationType.general:
      default:
        return Colors.purple;
    }
  }

  // Create a copy of this notification with some fields changed
  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionLink,
    Map<String, dynamic>? additionalData,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionLink: actionLink ?? this.actionLink,
      additionalData: additionalData ?? this.additionalData,
    );
  }
} 