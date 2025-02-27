class InventoryItem {
  final int? id;
  final String name;
  final String type; // 'raw_material', 'finished_product'
  final double quantity;
  final String unit; // 'pieces', 'kg', 'cubic_meters', etc.
  final double? price;
  final String? location;
  final String status; // 'in_stock', 'low_stock', 'out_of_stock'
  final String? description;
  final String? image;
  final String lastUpdated;

  InventoryItem({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    this.price,
    this.location,
    required this.status,
    this.description,
    this.image,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      location: json['location'],
      status: json['status'],
      description: json['description'],
      image: json['image'],
      lastUpdated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'location': location,
      'status': status,
      'description': description,
      'image': image,
      'last_updated': lastUpdated,
    };
  }
} 