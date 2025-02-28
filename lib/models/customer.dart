class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 