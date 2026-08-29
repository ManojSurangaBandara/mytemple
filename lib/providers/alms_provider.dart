import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/alms_booking_model.dart';
import '../../models/contributor_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';

enum AlmsFilterType { all, morningOnly, lunchOnly }
enum AlmsFilterStatus { all, availableOnly, assignedOnly, myOnly }

class AlmsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<AlmsBookingModel> _bookings = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  AlmsFilterType _filterType = AlmsFilterType.all;
  AlmsFilterStatus _filterStatus = AlmsFilterStatus.all;
  bool _isLoading = false;

  List<AlmsBookingModel> get allBookings => _bookings;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  AlmsFilterType get filterType => _filterType;
  AlmsFilterStatus get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;

  AlmsProvider() {
    loadBookings();
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();
    _bookings = await _storageService.loadBookings();
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void setFocusedMonth(DateTime month) {
    _focusedMonth = month;
    notifyListeners();
  }

  void setFilterType(AlmsFilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterStatus(AlmsFilterStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Get or create the standard morning and lunch slots for a specific date and temple
  List<AlmsBookingModel> getSlotsForDate({
    required String templeId,
    required DateTime date,
    int defaultMonksCount = 5,
  }) {
    final normalized = DateTime(date.year, date.month, date.day);
    final morningKey = AlmsBookingModel.generateSlotKey(normalized, AlmsType.morning);
    final lunchKey = AlmsBookingModel.generateSlotKey(normalized, AlmsType.lunch);

    AlmsBookingModel? morning = _bookings.cast<AlmsBookingModel?>().firstWhere(
      (b) => b!.templeId == templeId && b.slotKey == morningKey,
      orElse: () => null,
    );

    AlmsBookingModel? lunch = _bookings.cast<AlmsBookingModel?>().firstWhere(
      (b) => b!.templeId == templeId && b.slotKey == lunchKey,
      orElse: () => null,
    );

    // If slot doesn't exist yet in persistent list, create a virtual available slot
    morning ??= AlmsBookingModel(
      id: 'slot_${morningKey}_$templeId',
      templeId: templeId,
      date: normalized,
      almsType: AlmsType.morning,
      monksCount: defaultMonksCount,
      status: AlmsStatus.available,
    );

    lunch ??= AlmsBookingModel(
      id: 'slot_${lunchKey}_$templeId',
      templeId: templeId,
      date: normalized,
      almsType: AlmsType.lunch,
      monksCount: defaultMonksCount,
      status: AlmsStatus.available,
    );

    List<AlmsBookingModel> result = [morning, lunch];

    // Apply type filter
    if (_filterType == AlmsFilterType.morningOnly) {
      result = result.where((s) => s.isMorning).toList();
    } else if (_filterType == AlmsFilterType.lunchOnly) {
      result = result.where((s) => s.isLunch).toList();
    }

    return result;
  }

  /// Get all slots for a given day with applied status filters
  List<AlmsBookingModel> getFilteredSlotsForDate({
    required String templeId,
    required DateTime date,
    String? currentContributorId,
    int defaultMonksCount = 5,
  }) {
    final slots = getSlotsForDate(
      templeId: templeId,
      date: date,
      defaultMonksCount: defaultMonksCount,
    );

    if (_filterStatus == AlmsFilterStatus.availableOnly) {
      return slots.where((s) => s.isAvailable).toList();
    } else if (_filterStatus == AlmsFilterStatus.assignedOnly) {
      return slots.where((s) => s.isAssigned).toList();
    } else if (_filterStatus == AlmsFilterStatus.myOnly && currentContributorId != null) {
      return slots.where((s) => s.contributorId == currentContributorId).toList();
    }

    return slots;
  }

  /// Returns events list for TableCalendar marker dots
  List<AlmsBookingModel> getEventsForDay(DateTime day, String templeId) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _bookings
        .where((b) =>
            b.templeId == templeId &&
            b.date.year == normalized.year &&
            b.date.month == normalized.month &&
            b.date.day == normalized.day &&
            b.isAssigned)
        .toList();
  }

  /// Check if a day has all slots assigned or partial
  Map<String, dynamic> getDayStatusSummary(DateTime day, String templeId) {
    final normalized = DateTime(day.year, day.month, day.day);
    final morningKey = AlmsBookingModel.generateSlotKey(normalized, AlmsType.morning);
    final lunchKey = AlmsBookingModel.generateSlotKey(normalized, AlmsType.lunch);

    final morning = _bookings.any((b) => b.templeId == templeId && b.slotKey == morningKey && b.isAssigned);
    final lunch = _bookings.any((b) => b.templeId == templeId && b.slotKey == lunchKey && b.isAssigned);

    return {
      'hasMorning': morning,
      'hasLunch': lunch,
      'isFullyBooked': morning && lunch,
      'isPartiallyBooked': (morning && !lunch) || (!morning && lunch),
      'isEmpty': !morning && !lunch,
    };
  }

  /// Get upcoming bookings assigned to a specific contributor
  List<AlmsBookingModel> getMyUpcomingAlms({
    required String contributorId,
    required String templeId,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _bookings
        .where((b) =>
            b.templeId == templeId &&
            b.contributorId == contributorId &&
            !b.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Assign an Alms slot to a contributor and schedule the previous-day notification
  Future<AlmsBookingModel> assignAlmsSlot({
    required String templeId,
    required DateTime date,
    required AlmsType almsType,
    required ContributorModel contributor,
    required int monksCount,
    String? specialNotes,
    required String templeName,
    required bool isSinhala,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final slotKey = AlmsBookingModel.generateSlotKey(normalized, almsType);

    final index = _bookings.indexWhere((b) => b.templeId == templeId && b.slotKey == slotKey);

    final booking = AlmsBookingModel(
      id: index >= 0 ? _bookings[index].id : 'booking_${const Uuid().v4().substring(0, 8)}',
      templeId: templeId,
      date: normalized,
      almsType: almsType,
      contributorId: contributor.id,
      contributorName: contributor.fullName,
      contributorNameSi: contributor.fullNameSi,
      contributorPhone: contributor.phone,
      monksCount: monksCount,
      specialNotes: specialNotes,
      status: AlmsStatus.assigned,
      isReminderSent: false,
      reminderScheduledFor: _notificationService.getPreviousDayReminderTime(normalized),
    );

    if (index >= 0) {
      _bookings[index] = booking;
    } else {
      _bookings.add(booking);
    }

    await _storageService.saveBookings(_bookings);

    // Schedule automated previous-day reminder
    await _notificationService.schedulePreviousDayReminder(
      booking: booking,
      templeName: templeName,
      isSinhala: isSinhala,
    );

    notifyListeners();
    return booking;
  }

  /// Unassign / remove contributor from an alms slot
  Future<void> unassignAlmsSlot({
    required String templeId,
    required DateTime date,
    required AlmsType almsType,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final slotKey = AlmsBookingModel.generateSlotKey(normalized, almsType);

    final index = _bookings.indexWhere((b) => b.templeId == templeId && b.slotKey == slotKey);
    if (index >= 0) {
      final oldBooking = _bookings[index];
      await _notificationService.cancelReminder(oldBooking.id);

      _bookings.removeAt(index);
      await _storageService.saveBookings(_bookings);
      notifyListeners();
    }
  }

  /// Trigger a manual/instant reminder notification (for test & verification)
  Future<void> triggerInstantReminder({
    required AlmsBookingModel booking,
    required String templeName,
    required bool isSinhala,
  }) async {
    final isMorning = booking.isMorning;
    final slotTitle = isSinhala
        ? (isMorning ? 'හීල් දානය' : 'දිවා දානය')
        : (isMorning ? 'Morning Alms (Heel Dāna)' : 'Lunch Alms (Diwa Dāna)');

    final targetTimeStr = isMorning ? (isSinhala ? 'පෙ.ව. 6:00' : '6:00 AM') : (isSinhala ? 'පෙ.ව. 11:00' : '11:00 AM');
    final title = isSinhala
        ? 'මතක්කිරීම: හෙට දින $slotTitle ඔබගේ වාරයයි'
        : 'Reminder: Tomorrow is your $slotTitle turn';
    final body = isSinhala
        ? '$templeName විහාරස්ථානයේ සංඝරත්නය ${booking.monksCount} නමක් උදෙසා හෙට $slotTitle පිළියෙළ කිරීමට කාරුණික වන්න. $targetTimeStr ට පෙර රැගෙන එන්න.'
        : 'Tomorrow is your turn to provide $slotTitle for ${booking.monksCount} monks at $templeName. Please arrive by $targetTimeStr.';

    await _notificationService.showInstantNotification(
      id: booking.id.hashCode.abs() % 100000,
      title: title,
      body: body,
      payload: booking.id,
    );
  }
}
