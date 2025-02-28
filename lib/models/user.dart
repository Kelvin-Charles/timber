class User {
  final int id;
  final String username;
  final String email;
  final String role; // 'admin', 'manager', 'worker'
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null 
          ? (json['id'] is String ? int.tryParse(json['id']) : json['id']) 
          : 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
    };
  }
} 