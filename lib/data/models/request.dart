enum RequestStatus { pending, accepted, rejected }

enum AttendanceStatus { absent, attended }

class Request {
  final int id;
  final int gameId;
  final String userId;
  final RequestStatus status;
  final AttendanceStatus? attendance;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.status,
    this.attendance,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    final attendance =
        (json['attendance_status'] ?? json['attendance']) as String?;
    return Request(
      id: (json['id'] as num).toInt(),
      gameId: (json['game_id'] as num).toInt(),
      userId: '${json['user_id']}',
      status: RequestStatus.values.byName(json['status']),
      attendance: attendance == null
          ? null
          : AttendanceStatus.values.byName(attendance),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'user_id': userId,
      'status': status.name,
      'attendance': attendance?.name,
      'archived_at': archivedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
