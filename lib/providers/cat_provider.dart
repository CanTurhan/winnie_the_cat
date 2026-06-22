import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winnie_the_cat/models/cat_entry.dart';

class CatProvider extends ChangeNotifier {
  static const String _storageKey = 'cat_entries';

  final List<CatEntry> _cats = [];

  List<CatEntry> get cats => List.unmodifiable(_cats);

  Future<void> loadCats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      _cats.clear();
      notifyListeners();
      return;
    }

    final List<dynamic> decoded = json.decode(raw);

    _cats
      ..clear()
      ..addAll(
        decoded.map(
          (e) => CatEntry.fromMap(Map<String, dynamic>.from(e)),
        ),
      );

    _cats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> _saveCats() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_cats.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addCat(CatEntry cat) async {
    _cats.insert(0, cat);
    await _saveCats();
    notifyListeners();
  }

  Future<void> deleteCat(String id) async {
    final index = _cats.indexWhere((cat) => cat.id == id);
    if (index == -1) return;

    final imagePath = _cats[index].imagePath;

    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        try {
          await imageFile.delete();
        } catch (_) {}
      }
    }

    _cats.removeAt(index);
    await _saveCats();
    notifyListeners();
  }

  Future<void> feedCat(String id) async {
    final index = _cats.indexWhere((cat) => cat.id == id);
    if (index == -1) return;

    _cats[index] = _cats[index].copyWith(fedToday: true);
    await _saveCats();
    notifyListeners();
  }

  Future<void> markSeenToday(String id) async {
    final index = _cats.indexWhere((cat) => cat.id == id);
    if (index == -1) return;

    _cats[index] = _cats[index].copyWith(lastSeen: DateTime.now());
    await _saveCats();
    notifyListeners();
  }
}
