import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بنك الأسئلة الخطأ: يحتفظ بمعرّفات الأسئلة التي أُجيب عنها خطأ
/// ويُخزنها على الجهاز لتبقى بعد إغلاق التطبيق.
class MistakeStore extends ChangeNotifier {
  static const _key = 'mistake_ids_v1';
  List<String> ids = [];
  bool loaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '[]';
    try {
      ids = List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      ids = [];
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> add(String id) async {
    if (!ids.contains(id)) {
      ids.add(id);
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    if (ids.remove(id)) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    ids = [];
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids));
  }
}
