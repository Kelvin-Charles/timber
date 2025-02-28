class Order {
  final String id;
  final int customerId;
  final String orderDate;
  final String? deliveryDate;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final double totalAmount;
  final String? paymentStatus; // 'pending', 'partial', 'paid'
  final String? notes;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerId,
    required this.orderDate,
    this.deliveryDate,
    required this.status,
    required this.totalAmount,
    this.paymentStatus,
    this.notes,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parseItems() {
      try {
        if (json['items'] == null) {
          return [];
        }
        
        if (json['items'] is! List) {
          return [];
        }
        
        final itemsList = json['items'] as List;
        return itemsList.map((item) {
          try {
            return OrderItem.fromJson(item);
          } catch (e) {
            print('Error parsing order item: $e');
            return OrderItem(
              productId: 0,
              quantity: 0,
              unitPrice: 0.0,
            );
          }
        }).toList();
      } catch (e) {
        print('Error parsing items list: $e');
        return [];
      }
    }

    return Order(
      id: json['id']?.toString() ?? '0',
      customerId: json['customer_id'] is String 
          ? int.tryParse(json['customer_id']) ?? 0
          : json['customer_id'] ?? 0,
      orderDate: json['order_date'] ?? DateTime.now().toString().substring(0, 10),
      deliveryDate: json['delivery_date'],
      status: json['status'] ?? 'unknown',
      totalAmount: json['total_amount'] is String 
          ? double.tryParse(json['total_amount']) ?? 0.0
          : (json['total_amount'] ?? 0.0).toDouble(),
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      items: parseItems(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_date': orderDate,
      'delivery_date': deliveryDate,
      'status': status,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int productId;
  final int quantity;
  final double unitPrice;
  
  OrderItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] is String 
          ? int.parse(json['product_id']) 
          : json['product_id'],
      quantity: json['quantity'] is String 
          ? int.parse(json['quantity']) 
          : json['quantity'],
      unitPrice: json['unit_price'] is String 
          ? double.parse(json['unit_price']) 
          : json['unit_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
} 