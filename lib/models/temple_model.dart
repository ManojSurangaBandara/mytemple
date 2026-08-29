class TempleModel {
  final String id;
  final String nameEn;
  final String nameSi;
  final String address;
  final String district;
  final String contactNumber;
  final String chiefMonkName;
  final String chiefMonkNameSi;
  final String chiefMonkPhone;
  final int residentMonksCount;
  final String? imageUrl;
  final DateTime createdAt;

  TempleModel({
    required this.id,
    required this.nameEn,
    required this.nameSi,
    required this.address,
    required this.district,
    required this.contactNumber,
    required this.chiefMonkName,
    required this.chiefMonkNameSi,
    required this.chiefMonkPhone,
    required this.residentMonksCount,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TempleModel copyWith({
    String? id,
    String? nameEn,
    String? nameSi,
    String? address,
    String? district,
    String? contactNumber,
    String? chiefMonkName,
    String? chiefMonkNameSi,
    String? chiefMonkPhone,
    int? residentMonksCount,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return TempleModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameSi: nameSi ?? this.nameSi,
      address: address ?? this.address,
      district: district ?? this.district,
      contactNumber: contactNumber ?? this.contactNumber,
      chiefMonkName: chiefMonkName ?? this.chiefMonkName,
      chiefMonkNameSi: chiefMonkNameSi ?? this.chiefMonkNameSi,
      chiefMonkPhone: chiefMonkPhone ?? this.chiefMonkPhone,
      residentMonksCount: residentMonksCount ?? this.residentMonksCount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameSi': nameSi,
        'address': address,
        'district': district,
        'contactNumber': contactNumber,
        'chiefMonkName': chiefMonkName,
        'chiefMonkNameSi': chiefMonkNameSi,
        'chiefMonkPhone': chiefMonkPhone,
        'residentMonksCount': residentMonksCount,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TempleModel.fromJson(Map<String, dynamic> json) => TempleModel(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameSi: json['nameSi'] as String? ?? json['nameEn'] as String,
        address: json['address'] as String,
        district: json['district'] as String,
        contactNumber: json['contactNumber'] as String,
        chiefMonkName: json['chiefMonkName'] as String,
        chiefMonkNameSi: json['chiefMonkNameSi'] as String? ?? json['chiefMonkName'] as String,
        chiefMonkPhone: json['chiefMonkPhone'] as String? ?? '',
        residentMonksCount: json['residentMonksCount'] as int? ?? 5,
        imageUrl: json['imageUrl'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
