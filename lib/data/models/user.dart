class User {
  final int id;
  final String fullname;
  final String username;
  final String phoneNumber;
  final String position;
  final String level;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.phoneNumber,
    required this.position,
    required this.level,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      position: json['position'],
      level: json['level'],
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'phone_number': phoneNumber,
      'position': position,
      'level': level,
      'rating': rating,
      'rating_count': ratingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
