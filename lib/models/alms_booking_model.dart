enum AlmsType {
  morning, // Heel Dāna (හීල් දානය)
  lunch, // Diwa Dāna (දිවා දානය)
}

enum AlmsStatus {
  available, // Not assigned yet
  assigned, // Assigned to a contributor
  completed, // Dāna delivered / past
}

class AlmsBookingModel {
  final String id;
  final String templeId;
  final DateTime date; // Normalized to yyyy-MM-dd
  final AlmsType almsType;
  final String? contributorId;
  final String? contributorName;
  final String? contributorNameSi;
  final String? contributorPhone;
  final int monksCount;
  final String? specialNotes;
  final AlmsStatus status;
  final bool isReminderSent;
  final DateTime? reminderScheduledFor;
  final DateTime createdAt;

  AlmsBookingModel({
    required this.id,
    required this.templeId,
    required this.date,
    required this.almsType,
    this.contributorId,
    this.contributorName,
    this.contributorNameSi,
    this.contributorPhone,
    this.monksCount = 5,
    this.specialNotes,
    this.status = AlmsStatus.available,
    this.isReminderSent = false,
    this.reminderScheduledFor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isMorning => almsType == AlmsType.morning;
  bool get isLunch => almsType == AlmsType.lunch;
  bool get isAssigned => status == AlmsStatus.assigned && contributorId != null;
  bool get isAvailable => status == AlmsStatus.available || contributorId == null;

  String get slotKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_${almsType.name}';

  static String generateSlotKey(DateTime d, AlmsType type) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}_${type.name}';
  }

  AlmsBookingModel copyWith({
    String? id,
    String? templeId,
    DateTime? date,
    AlmsType? almsType,
    String? contributorId,
    String? contributorName,
    String? contributorNameSi,
    String? contributorPhone,
    int? monksCount,
    String? specialNotes,
    AlmsStatus? status,
    bool? isReminderSent,
    DateTime? reminderScheduledFor,
    DateTime? createdAt,
  }) {
    return AlmsBookingModel(
      id: id ?? this.id,
      templeId: templeId ?? this.templeId,
      date: date ?? this.date,
      almsType: almsType ?? this.almsType,
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      contributorNameSi: contributorNameSi ?? this.contributorNameSi,
      contributorPhone: contributorPhone ?? this.contributorPhone,
      monksCount: monksCount ?? this.monksCount,
      specialNotes: specialNotes ?? this.specialNotes,
      status: status ?? this.status,
      isReminderSent: isReminderSent ?? this.isReminderSent,
      reminderScheduledFor: reminderScheduledFor ?? this.reminderScheduledFor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templeId': templeId,
        'date': date.toIso8601String(),
        'almsType': almsType.name,
        'contributorId': contributorId,
        'contributorName': contributorName,
        'contributorNameSi': contributorNameSi,
        'contributorPhone': contributorPhone,
        'monksCount': monksCount,
        'specialNotes': specialNotes,
        'status': status.name,
        'isReminderSent': isReminderSent,
        'reminderScheduledFor': reminderScheduledFor?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AlmsBookingModel.fromJson(Map<String, dynamic> json) =>
      AlmsBookingModel(
        id: json['id'] as String,
        templeId: json['templeId'] as String,
        date: DateTime.parse(json['date'] as String),
        almsType: AlmsType.values.firstWhere(
          (e) => e.name == json['almsType'],
          orElse: () => AlmsType.morning,
        ),
        contributorId: json['contributorId'] as String?,
        contributorName: json['contributorName'] as String?,
        contributorNameSi: json['contributorNameSi'] as String?,
        contributorPhone: json['contributorPhone'] as String?,
        monksCount: json['monksCount'] as int? ?? 5,
        specialNotes: json['specialNotes'] as String?,
        status: AlmsStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AlmsStatus.available,
        ),
        isReminderSent: json['isReminderSent'] as bool? ?? false,
        reminderScheduledFor: json['reminderScheduledFor'] != null
            ? DateTime.parse(json['reminderScheduledFor'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
