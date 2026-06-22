import 'dart:convert';

class CatEntry {
  final String id;
  final String name;
  final String place;
  final String note;
  final String? imagePath;
  final DateTime lastSeen;
  final bool fedToday;
  final DateTime createdAt;

  CatEntry({
    required this.id,
    required this.name,
    required this.place,
    required this.note,
    required this.imagePath,
    required this.lastSeen,
    required this.fedToday,
    required this.createdAt,
  });

  CatEntry copyWith({
    String? id,
    String? name,
    String? place,
    String? note,
    String? imagePath,
    DateTime? lastSeen,
    bool? fedToday,
    DateTime? createdAt,
  }) {
    return CatEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      lastSeen: lastSeen ?? this.lastSeen,
      fedToday: fedToday ?? this.fedToday,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'place': place,
      'note': note,
      'imagePath': imagePath,
      'lastSeen': lastSeen.toIso8601String(),
      'fedToday': fedToday,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CatEntry.fromMap(Map<String, dynamic> map) {
    return CatEntry(
      id: map['id'],
      name: map['name'],
      place: map['place'],
      note: map['note'] ?? '',
      imagePath: map['imagePath'],
      lastSeen: DateTime.parse(map['lastSeen']),
      fedToday: map['fedToday'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CatEntry.fromJson(String source) =>
      CatEntry.fromMap(json.decode(source));
}
