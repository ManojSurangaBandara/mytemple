class ContributorModel {
  final String id;
  final String templeId;
  final String fullName;
  final String fullNameSi;
  final String phone;
  final String address;
  final String? familyName; // Vasagama
  final String? notes;
  final DateTime joinedDate;
  final int totalDonationsCount;

  ContributorModel({
    required this.id,
    required this.templeId,
    required this.fullName,
    required this.fullNameSi,
    required this.phone,
    required this.address,
    this.familyName,
    this.notes,
    DateTime? joinedDate,
    this.totalDonationsCount = 0,
  }) : joinedDate = joinedDate ?? DateTime.now();

  ContributorModel copyWith({
    String? id,
    String? templeId,
    String? fullName,
    String? fullNameSi,
    String? phone,
    String? address,
    String? familyName,
    String? notes,
    DateTime? joinedDate,
    int? totalDonationsCount,
  }) {
    return ContributorModel(
      id: id ?? this.id,
      templeId: templeId ?? this.templeId,
      fullName: fullName ?? this.fullName,
      fullNameSi: fullNameSi ?? this.fullNameSi,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      familyName: familyName ?? this.familyName,
      notes: notes ?? this.notes,
      joinedDate: joinedDate ?? this.joinedDate,
      totalDonationsCount: totalDonationsCount ?? this.totalDonationsCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templeId': templeId,
        'fullName': fullName,
        'fullNameSi': fullNameSi,
        'phone': phone,
        'address': address,
        'familyName': familyName,
        'notes': notes,
        'joinedDate': joinedDate.toIso8601String(),
        'totalDonationsCount': totalDonationsCount,
      };

  factory ContributorModel.fromJson(Map<String, dynamic> json) =>
      ContributorModel(
        id: json['id'] as String,
        templeId: json['templeId'] as String,
        fullName: json['fullName'] as String,
        fullNameSi: json['fullNameSi'] as String? ?? json['fullName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String? ?? '',
        familyName: json['familyName'] as String?,
        notes: json['notes'] as String?,
        joinedDate: json['joinedDate'] != null
            ? DateTime.parse(json['joinedDate'] as String)
            : DateTime.now(),
        totalDonationsCount: json['totalDonationsCount'] as int? ?? 0,
      );
}
