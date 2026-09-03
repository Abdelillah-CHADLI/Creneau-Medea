import 'package:flutter/material.dart';

enum RequestType { needPlayers, lookingForOpponent, pitchAvailable }

extension RequestTypeExt on RequestType {
  String get label {
    switch (this) {
      case RequestType.needPlayers:
        return 'نحتاج لاعبين';
      case RequestType.lookingForOpponent:
        return 'نبحث عن خصم';
      case RequestType.pitchAvailable:
        return 'الملعب متاح هذا الأسبوع';
    }
  }

  String get description {
    switch (this) {
      case RequestType.needPlayers:
        return 'أكمل تشكيلة فريقك للمباراة القادمة';
      case RequestType.lookingForOpponent:
        return 'لدينا فريق ونبحث عن فريق منافس';
      case RequestType.pitchAvailable:
        return 'اعرض وقتاً متاحاً في ملعبك للاعبين الآخرين';
    }
  }

  IconData get icon {
    switch (this) {
      case RequestType.needPlayers:
        return Icons.person_add_outlined;
      case RequestType.lookingForOpponent:
        return Icons.sports_mma_outlined;
      case RequestType.pitchAvailable:
        return Icons.stadium_outlined;
    }
  }
}

class CreateRequestData {
  RequestType? type;
  String? title;
  String? pitchName;
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? playerCount;
  int? price;
  List<String> equipment = [];
  String? notes;

  bool get isStep1Complete => type != null;

  bool get isStep2Complete =>
      title?.trim().isNotEmpty == true &&
      pitchName != null &&
      date != null &&
      startTime != null &&
      endTime != null;

  bool get isStep4Complete => true;
}
