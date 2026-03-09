import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/daora_service.dart';

class Daorastate extends ChangeNotifier {
  final DaoraService _daoraService = DaoraService();

  // 🆕 الدورة الحالية
  int? _currentDaoraId;

  int? get currentDaoraId => _currentDaoraId;

  Future<void> loadDaoraId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDaoraId = prefs.getInt("currentDaoraId");
    notifyListeners();
  }

  Future<void> setDaoraId(int id) async {
    _currentDaoraId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("currentDaoraId", id);
    notifyListeners();
  }

  // 📸 كاش صور
  final int _cacheLimit = 20; // الحد الأقصى لعدد الصور

  /// كاش للصور
  final Map<int, String?> _photosCache = {};

  Future<String?> getDaoraPhotos(int daoraId) async {
    if (_photosCache.containsKey(daoraId)) {
      return _photosCache[daoraId];
    }

    final photoBase64 = await _daoraService.fetchDaoraPhoto(daoraId);

    if (photoBase64 != null) {
      // 🧹 تحقق من الحد
      if (_photosCache.length >= _cacheLimit) {
        final firstKey = _photosCache.keys.first;
        _photosCache.remove(firstKey);
      }

      _photosCache[daoraId] = photoBase64;
    } else {
      _photosCache[daoraId] = null;
    }

    return photoBase64;
  }

  void clearPhotosCache() {
    _photosCache.clear();
  }

  Future<List<dynamic>> getAllDaoras() async {
    return await _daoraService.getAllDaoras();
  }

  Future<String> deleteDaora(int id, String? token) async {
    return await _daoraService.deleteDaora(id, token);
  }

  Future<String> addDaora(
    String daoraName,
    String adminName,
    String password,
    File? photo,
    String? token,
  ) async {
    return await _daoraService.addDaora(
        daoraName, adminName, password, photo, token);
  }

  Future<Map<String, dynamic>> changeMyDaora(int userId, int newDaoraId) async {
    final result = await _daoraService.changeMyDaora(userId, newDaoraId);
    if (result['success'] == true) {
      await setDaoraId(newDaoraId);
    }
    return result;
  }

  Future<Map<String, List<dynamic>>> getJobsAndAreas(String? token) async {
    return await _daoraService.getJobsAndAreas(token);
  }
}
