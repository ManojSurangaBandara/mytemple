import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel _currentUser = StorageService.getInitialUsers()[1]; // Default to Chief Monk for rich immediate experience
  final List<UserModel> _availableDemoUsers = StorageService.getInitialUsers();

  UserModel get currentUser => _currentUser;
  UserRole get currentRole => _currentUser.role;
  List<UserModel> get availableDemoUsers => _availableDemoUsers;

  bool get isSuperAdmin => _currentUser.isSuperAdmin;
  bool get isTempleAdmin => _currentUser.isTempleAdmin;
  bool get isContributor => _currentUser.isContributor;

  String? get activeTempleId => _currentUser.assignedTempleId;
  String? get activeContributorId => _currentUser.contributorId;

  void switchUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void switchRole(UserRole role) {
    final match = _availableDemoUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => _currentUser,
    );
    _currentUser = match;
    notifyListeners();
  }

  void setChiefMonkForTemple(String templeId, String monkName, String monkNameSi, String monkPhone) {
    // Check if user already exists
    final index = _availableDemoUsers.indexWhere((u) => u.assignedTempleId == templeId && u.role == UserRole.templeAdmin);
    final monkUser = UserModel(
      id: index >= 0 ? _availableDemoUsers[index].id : 'monk_${DateTime.now().millisecondsSinceEpoch}',
      fullName: monkName,
      fullNameSi: monkNameSi,
      phone: monkPhone,
      email: '${monkName.toLowerCase().replaceAll(' ', '.')}@mytemple.lk',
      role: UserRole.templeAdmin,
      assignedTempleId: templeId,
    );

    if (index >= 0) {
      _availableDemoUsers[index] = monkUser;
    } else {
      _availableDemoUsers.add(monkUser);
    }
    notifyListeners();
  }
}
