class Need {
  final int id;
  final String name;

  Need({required this.id, required this.name});

  factory Need.fromJson(Map<String, dynamic> json) {
    return Need(id: (json['id'] as num).toInt(), name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
