class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int totalOrders;
  final double? totalSpent;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.totalOrders,
    this.totalSpent,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: json['total_spent'] != null 
          ? double.parse(json['total_spent'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
    };
  }
} 