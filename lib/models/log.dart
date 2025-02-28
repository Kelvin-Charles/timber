class Log {
  final int? id;
  final String logNumber;
  final String species;
  final double diameter;
  final double length;
  final String quality;
  final String source;
  final String receivedDate;
  final String status;
  final String? notes;

  Log({
    this.id,
    required this.logNumber,
    required this.species,
    required this.diameter,
    required this.length,
    required this.quality,
    required this.source,
    required this.receivedDate,
    required this.status,
    this.notes,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'],
      logNumber: json['log_number'],
      species: json['species'],
      diameter: double.parse(json['diameter'].toString()),
      length: double.parse(json['length'].toString()),
      quality: json['quality'],
      source: json['source'],
      receivedDate: json['received_date'],
      status: json['status'],
      notes: json['notes'],
    );
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
      'received_date': receivedDate,
      'status': status,
      'notes': notes,
    };
  }
} 