import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/contributor_model.dart';
import '../../core/services/storage_service.dart';

class ContributorProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ContributorModel> _contributors = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ContributorModel> get allContributors => _contributors;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  ContributorProvider() {
    loadContributors();
  }

  Future<void> loadContributors() async {
    _isLoading = true;
    notifyListeners();
    _contributors = await _storageService.loadContributors();
    _isLoading = false;
    notifyListeners();
  }

  List<ContributorModel> getContributorsForTemple(String templeId) {
    var list = _contributors.where((c) => c.templeId == templeId).toList();
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((c) =>
          c.fullName.toLowerCase().contains(query) ||
          c.fullNameSi.contains(query) ||
          c.phone.contains(query) ||
          (c.familyName != null && c.familyName!.toLowerCase().contains(query))).toList();
    }
    return list;
  }

  ContributorModel? getContributorById(String? id) {
    if (id == null) return null;
    try {
      return _contributors.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<ContributorModel> addContributor({
    required String templeId,
    required String fullName,
    required String fullNameSi,
    required String phone,
    required String address,
    String? familyName,
    String? notes,
  }) async {
    final newContributor = ContributorModel(
      id: 'contributor_${const Uuid().v4().substring(0, 8)}',
      templeId: templeId,
      fullName: fullName,
      fullNameSi: fullNameSi.trim().isEmpty ? fullName : fullNameSi,
      phone: phone,
      address: address,
      familyName: familyName,
      notes: notes,
      joinedDate: DateTime.now(),
      totalDonationsCount: 0,
    );

    _contributors.add(newContributor);
    await _storageService.saveContributors(_contributors);
    notifyListeners();
    return newContributor;
  }

  Future<void> updateContributor(ContributorModel updated) async {
    final index = _contributors.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      _contributors[index] = updated;
      await _storageService.saveContributors(_contributors);
      notifyListeners();
    }
  }

  Future<void> incrementDonationCount(String contributorId) async {
    final index = _contributors.indexWhere((c) => c.id == contributorId);
    if (index >= 0) {
      _contributors[index] = _contributors[index].copyWith(
        totalDonationsCount: _contributors[index].totalDonationsCount + 1,
      );
      await _storageService.saveContributors(_contributors);
      notifyListeners();
    }
  }

  Future<void> deleteContributor(String id) async {
    _contributors.removeWhere((c) => c.id == id);
    await _storageService.saveContributors(_contributors);
    notifyListeners();
  }
}
