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
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      orderDate: json['order_date'],
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryDate: json['delivery_date'],
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      items: json['items'] != null
          ? List<OrderItem>.from(json['items'].map((x) => OrderItem.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_date': orderDate,
      'status': status,
      'total_amount': totalAmount,
      'delivery_date': deliveryDate,
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
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
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