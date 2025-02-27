class Customer {
  final int? id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? company;
  final String? notes;
  final String createdDate;
  final int totalOrders;
  final double? totalSpent;

  Customer({
    this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.company,
    this.notes,
    required this.createdDate,
    required this.totalOrders,
    this.totalSpent,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      company: json['company'],
      notes: json['notes'],
      createdDate: json['created_date'],
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
      'phone_number': phoneNumber,
      'address': address,
      'company': company,
      'notes': notes,
      'created_date': createdDate,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
    };
  }
} 