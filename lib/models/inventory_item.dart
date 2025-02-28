class InventoryItem {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double? price;
  final String status;
  
  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.price,
    required this.status,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'status': status,
    };
  }
} 