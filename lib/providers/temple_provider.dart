import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/temple_model.dart';
import '../../core/services/storage_service.dart';

class TempleProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<TempleModel> _temples = [];
  String _selectedTempleId = 'temple_1';
  bool _isLoading = false;

  List<TempleModel> get temples => _temples;
  String get selectedTempleId => _selectedTempleId;
  bool get isLoading => _isLoading;

  TempleModel? get currentTemple {
    try {
      return _temples.firstWhere((t) => t.id == _selectedTempleId);
    } catch (_) {
      return _temples.isNotEmpty ? _temples.first : null;
    }
  }

  TempleProvider() {
    loadTemples();
  }

  Future<void> loadTemples() async {
    _isLoading = true;
    notifyListeners();
    _temples = await _storageService.loadTemples();
    if (_temples.isNotEmpty && !_temples.any((t) => t.id == _selectedTempleId)) {
      _selectedTempleId = _temples.first.id;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectTemple(String templeId) {
    if (_selectedTempleId != templeId) {
      _selectedTempleId = templeId;
      notifyListeners();
    }
  }

  Future<TempleModel> addTemple({
    required String nameEn,
    required String nameSi,
    required String address,
    required String district,
    required String contactNumber,
    required String chiefMonkName,
    required String chiefMonkNameSi,
    required String chiefMonkPhone,
    required int residentMonksCount,
  }) async {
    final newTemple = TempleModel(
      id: 'temple_${const Uuid().v4().substring(0, 8)}',
      nameEn: nameEn,
      nameSi: nameSi,
      address: address,
      district: district,
      contactNumber: contactNumber,
      chiefMonkName: chiefMonkName,
      chiefMonkNameSi: chiefMonkNameSi,
      chiefMonkPhone: chiefMonkPhone,
      residentMonksCount: residentMonksCount,
    );

    _temples.add(newTemple);
    await _storageService.saveTemples(_temples);
    notifyListeners();
    return newTemple;
  }

  Future<void> updateTemple(TempleModel updated) async {
    final index = _temples.indexWhere((t) => t.id == updated.id);
    if (index >= 0) {
      _temples[index] = updated;
      await _storageService.saveTemples(_temples);
      notifyListeners();
    }
  }

  Future<void> updateChiefMonk({
    required String templeId,
    required String chiefMonkName,
    required String chiefMonkNameSi,
    required String chiefMonkPhone,
  }) async {
    final index = _temples.indexWhere((t) => t.id == templeId);
    if (index >= 0) {
      _temples[index] = _temples[index].copyWith(
        chiefMonkName: chiefMonkName,
        chiefMonkNameSi: chiefMonkNameSi,
        chiefMonkPhone: chiefMonkPhone,
      );
      await _storageService.saveTemples(_temples);
      notifyListeners();
    }
  }

  Future<void> deleteTemple(String templeId) async {
    _temples.removeWhere((t) => t.id == templeId);
    if (_selectedTempleId == templeId && _temples.isNotEmpty) {
      _selectedTempleId = _temples.first.id;
    }
    await _storageService.saveTemples(_temples);
    notifyListeners();
  }
}
