class Log {
  final String id;
  final String logNumber;
  final String species;
  final double diameter;
  final double length;
  final String quality;
  final String source;
  final String status;
  final String receivedDate;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Log({
    required this.id,
    required this.logNumber,
    required this.species,
    required this.diameter,
    required this.length,
    required this.quality,
    required this.source,
    required this.status,
    required this.receivedDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Static factory method for safer creation
  static Log fromJson(Map<String, dynamic> json) {
    try {
      print('Creating Log from JSON: ${json['id']}, ${json['log_number']}');
      
      // Parse numeric values safely
      double parseDiameter() {
        try {
          return double.parse(json['diameter'].toString());
        } catch (e) {
          print('Error parsing diameter: $e');
          return 0.0;
        }
      }
      
      double parseLength() {
        try {
          return double.parse(json['length'].toString());
        } catch (e) {
          print('Error parsing length: $e');
          return 0.0;
        }
      }
      
      return Log(
        id: json['id'].toString(),
        logNumber: json['log_number'] ?? 'Unknown',
        species: json['species'] ?? 'Unknown',
        diameter: parseDiameter(),
        length: parseLength(),
        quality: json['quality'] ?? 'Unknown',
        source: json['source'] ?? 'Unknown',
        status: json['status'] ?? 'Unknown',
        receivedDate: json['received_date'] ?? 'Unknown',
        notes: json['notes'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error in Log.fromJson: $e');
      throw Exception('Failed to create Log from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'log_number': logNumber,
      'species': species,
      'diameter': diameter,
      'length': length,
      'quality': quality,
      'source': source,
      'status': status,
      'received_date': receivedDate,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 