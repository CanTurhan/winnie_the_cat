import 'dart:convert';

class CatEntry {
  final String id;
  final String name;
  final String place;
  final String note;
  final List<String> imagePaths;
  final DateTime lastSeen;
  final bool fedToday;
  final DateTime createdAt;

  CatEntry({
    required this.id,
    required this.name,
    required this.place,
    required this.note,
    required this.imagePaths,
    required this.lastSeen,
    required this.fedToday,
    required this.createdAt,
  });

  String? get imagePath => imagePaths.isEmpty ? null : imagePaths.first;

  CatEntry copyWith({
    String? id,
    String? name,
    String? place,
    String? note,
    List<String>? imagePaths,
    DateTime? lastSeen,
    bool? fedToday,
    DateTime? createdAt,
  }) {
    return CatEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      note: note ?? this.note,
      imagePaths: imagePaths ?? this.imagePaths,
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
      'imagePaths': imagePaths,
      'imagePath': imagePath,
      'lastSeen': lastSeen.toIso8601String(),
      'fedToday': fedToday,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CatEntry.fromMap(Map<String, dynamic> map) {
    final List<String> paths = [];

    if (map['imagePaths'] is List) {
      paths.addAll(
        (map['imagePaths'] as List)
            .whereType<String>()
            .where((path) => path.trim().isNotEmpty),
      );
    }

    if (paths.isEmpty &&
        map['imagePath'] is String &&
        (map['imagePath'] as String).trim().isNotEmpty) {
      paths.add(map['imagePath']);
    }

    return CatEntry(
      id: map['id'],
      name: map['name'],
      place: map['place'],
      note: map['note'] ?? '',
      imagePaths: paths,
      lastSeen: DateTime.parse(map['lastSeen']),
      fedToday: map['fedToday'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CatEntry.fromJson(String source) =>
      CatEntry.fromMap(json.decode(source));
}
