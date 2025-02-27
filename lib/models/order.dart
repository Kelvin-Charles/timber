class Order {
  final int? id;
  final int customerId;
  final String orderDate;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final double totalAmount;
  final String? deliveryDate;
  final String? paymentStatus; // 'pending', 'partial', 'paid'
  final String? notes;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.customerId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    this.deliveryDate,
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
  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: double.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
} 