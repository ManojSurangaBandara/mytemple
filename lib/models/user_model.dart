enum UserRole {
  superAdmin,
  templeAdmin, // Chief Monk
  contributor, // Dayaka
}

class UserModel {
  final String id;
  final String fullName;
  final String fullNameSi;
  final String phone;
  final String email;
  final UserRole role;
  final String? assignedTempleId;
  final String? contributorId;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.fullNameSi,
    required this.phone,
    required this.email,
    required this.role,
    this.assignedTempleId,
    this.contributorId,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isTempleAdmin => role == UserRole.templeAdmin;
  bool get isContributor => role == UserRole.contributor;

  String get roleDisplayName {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.templeAdmin:
        return 'Chief Monk';
      case UserRole.contributor:
        return 'Contributor';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'fullNameSi': fullNameSi,
        'phone': phone,
        'email': email,
        'role': role.name,
        'assignedTempleId': assignedTempleId,
        'contributorId': contributorId,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        fullNameSi: json['fullNameSi'] as String? ?? json['fullName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.contributor,
        ),
        assignedTempleId: json['assignedTempleId'] as String?,
        contributorId: json['contributorId'] as String?,
      );
}
