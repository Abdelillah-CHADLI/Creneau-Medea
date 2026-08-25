enum ConditionType { bad, average, good }

class Pitch {
  final int id;
  final String name;
  final String location;
  final ConditionType condition;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pitch({
    required this.id,
    required this.name,
    required this.location,
    required this.condition,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pitch.fromJson(Map<String, dynamic> json) {
    return Pitch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      condition: ConditionType.values.byName(json['condition']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'condition': condition.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
