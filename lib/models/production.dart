class Production {
  final int id;
  final String productName;
  final String startDate;
  final String? endDate;
  final String status;
  final String currentStage;
  final double completionPercentage;
  
  Production({
    required this.id,
    required this.productName,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.currentStage,
    required this.completionPercentage,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      productName: json['product_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      currentStage: json['current_stage'],
      completionPercentage: double.parse(json['completion_percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'current_stage': currentStage,
      'completion_percentage': completionPercentage,
    };
  }
} 