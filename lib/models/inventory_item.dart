class InventoryItem {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final String status;
  final double? price;
  final String? location;
  final String? notes;
  
  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.status,
    this.price,
    this.location,
    this.notes,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      status: json['status'],
      price: json['price']?.toDouble(),
      location: json['location'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'status': status,
      'price': price,
      'location': location,
      'notes': notes,
    };
  }
} 