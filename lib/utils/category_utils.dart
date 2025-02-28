import 'package:flutter/material.dart';

class CategoryUtils {
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'raw materials':
        return Colors.green;
      case 'finished products':
        return Colors.blue;
      case 'tools':
        return Colors.orange;
      case 'supplies':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'raw materials':
        return Icons.forest;
      case 'finished products':
        return Icons.inventory;
      case 'tools':
        return Icons.handyman;
      case 'supplies':
        return Icons.category;
      default:
        return Icons.inventory_2;
    }
  }
} 