class Production {
  final int? id;
  final String productName;
  final String currentStage; // 'planning', 'cutting', 'assembly', 'finishing', 'quality_check', 'completed'
  final String startDate;
  final String? endDate;
  final int? assignedTo; // User ID
  final String status; // 'not_started', 'in_progress', 'on_hold', 'completed'
  final List<int>? usedLogs; // List of log IDs used in this production
  final String? notes;
  final double completionPercentage;

  Production({
    this.id,
    required this.productName,
    required this.currentStage,
    required this.startDate,
    this.endDate,
    this.assignedTo,
    required this.status,
    this.usedLogs,
    this.notes,
    required this.completionPercentage,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      productName: json['product_name'],
      currentStage: json['current_stage'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      assignedTo: json['assigned_to'],
      status: json['status'],
      usedLogs: json['used_logs'] != null 
          ? List<int>.from(json['used_logs'].map((x) => x))
          : null,
      notes: json['notes'],
      completionPercentage: double.parse(json['completion_percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'current_stage': currentStage,
      'start_date': startDate,
      'end_date': endDate,
      'assigned_to': assignedTo,
      'status': status,
      'used_logs': usedLogs,
      'notes': notes,
      'completion_percentage': completionPercentage,
    };
  }
} 