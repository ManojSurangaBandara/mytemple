import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/temple_model.dart';
import '../../models/contributor_model.dart';
import '../../models/alms_booking_model.dart';

class StorageService {
  static const String _keyTemples = 'mytemple_temples_v1';
  static const String _keyContributors = 'mytemple_contributors_v1';
  static const String _keyBookings = 'mytemple_bookings_v1';

  // Seed initial temples
  static List<TempleModel> getInitialTemples() {
    return [
      TempleModel(
        id: 'temple_1',
        nameEn: 'Bellanwila Rajamaha Viharaya',
        nameSi: 'බෙල්ලන්විල රජමහා විහාරය',
        address: 'Bellanwila, Boralesgamuwa, Colombo',
        district: 'Colombo',
        contactNumber: '+94 11 280 8822',
        chiefMonkName: 'Ven. Bellanwila Dhammarathana Nayaka Thero',
        chiefMonkNameSi: 'පූජ්‍ය ආචාර්ය බෙල්ලන්විල ධම්මරතන නායක ස්වාමීන් වහන්සේ',
        chiefMonkPhone: '+94 77 123 4567',
        residentMonksCount: 8,
        imageUrl: null,
      ),
      TempleModel(
        id: 'temple_2',
        nameEn: 'Hunupitiya Gangaramaya Temple',
        nameSi: 'හුණුපිටිය ගංගාරාම විහාරස්ථානය',
        address: '61 Sri Jinarathana Rd, Colombo 02',
        district: 'Colombo',
        contactNumber: '+94 11 243 5169',
        chiefMonkName: 'Ven. Dr. Kirinde Assaji Thero',
        chiefMonkNameSi: 'පූජ්‍ය ආචාර්ය කිරිඳේ අස්සජී නායක ස්වාමීන් වහන්සේ',
        chiefMonkPhone: '+94 71 987 6543',
        residentMonksCount: 12,
        imageUrl: null,
      ),
      TempleModel(
        id: 'temple_3',
        nameEn: 'Sri Dalada Maligawa (Temple of the Sacred Tooth)',
        nameSi: 'ශ්‍රී දළදා මාළිගාව',
        address: 'Sri Dalada Veediya, Kandy',
        district: 'Kandy',
        contactNumber: '+94 81 223 4223',
        chiefMonkName: 'Most Ven. Tibbatuwawe Sri Siddhartha Sumangala Mahanayake Thero',
        chiefMonkNameSi: 'අතිපූජ්‍ය තිබ්බටුවාවේ ශ්‍රී සිද්ධාර්ථ සුමංගල මහානායක ස්වාමීන් වහන්සේ',
        chiefMonkPhone: '+94 81 222 3344',
        residentMonksCount: 15,
        imageUrl: null,
      ),
    ];
  }

  // Seed demo users (Super Admin, Chief Monk, Contributor)
  static List<UserModel> getInitialUsers() {
    return [
      const UserModel(
        id: 'user_super_admin',
        fullName: 'Ven. Mahanayaka Board Admin',
        fullNameSi: 'මහානායක මණ්ඩල ප්‍රධාන පරිපාලක',
        phone: '+94 77 000 1111',
        email: 'superadmin@mytemple.lk',
        role: UserRole.superAdmin,
      ),
      const UserModel(
        id: 'user_chief_monk_1',
        fullName: 'Ven. Bellanwila Dhammarathana Thero',
        fullNameSi: 'පූජ්‍ය බෙල්ලන්විල ධම්මරතන නායක හිමි',
        phone: '+94 77 123 4567',
        email: 'bellanwila@mytemple.lk',
        role: UserRole.templeAdmin,
        assignedTempleId: 'temple_1',
      ),
      const UserModel(
        id: 'user_contributor_1',
        fullName: 'Mr. Sunil Perera',
        fullNameSi: 'සුනිල් පෙරේරා මහතා',
        phone: '+94 71 234 5678',
        email: 'sunil.perera@gmail.com',
        role: UserRole.contributor,
        assignedTempleId: 'temple_1',
        contributorId: 'contributor_1',
      ),
    ];
  }

  // Seed contributors for Bellanwila temple
  static List<ContributorModel> getInitialContributors() {
    return [
      ContributorModel(
        id: 'contributor_1',
        templeId: 'temple_1',
        fullName: 'Mr. Sunil Perera',
        fullNameSi: 'සුනිල් පෙරේරා මහතා',
        phone: '+94 71 234 5678',
        address: 'No. 45, Temple Road, Boralesgamuwa',
        familyName: 'Perera Family (පෙරේරා පවුල)',
        notes: 'Frequent donor for Poya days & Hil Dāna',
        joinedDate: DateTime(2022, 1, 15),
        totalDonationsCount: 14,
      ),
      ContributorModel(
        id: 'contributor_2',
        templeId: 'temple_1',
        fullName: 'Mrs. Malini Wickramasinghe',
        fullNameSi: 'මාලිනී වික්‍රමසිංහ මහත්මිය',
        phone: '+94 77 345 6789',
        address: 'No. 12, Lake View Gardens, Bellanwila',
        familyName: 'Wickramasinghe Family (වික්‍රමසිංහ පවුල)',
        notes: 'Provides special herbal porridge and fruits',
        joinedDate: DateTime(2021, 5, 20),
        totalDonationsCount: 22,
      ),
      ContributorModel(
        id: 'contributor_3',
        templeId: 'temple_1',
        fullName: 'Mr. Chaminda Silva',
        fullNameSi: 'චමින්ද සිල්වා මහතා',
        phone: '+94 78 456 7890',
        address: 'No. 88/2, High Level Road, Maharagama',
        familyName: 'Silva Family (සිල්වා පවුල)',
        notes: 'Diwa Dana donor',
        joinedDate: DateTime(2023, 2, 10),
        totalDonationsCount: 8,
      ),
      ContributorModel(
        id: 'contributor_4',
        templeId: 'temple_1',
        fullName: 'Mrs. Anula Rathnayake',
        fullNameSi: 'අනුලා රත්නායක මහත්මිය',
        phone: '+94 72 567 8901',
        address: 'No. 24, Dehiwala Road, Boralesgamuwa',
        familyName: 'Rathnayake Family (රත්නායක පවුල)',
        notes: 'Special alms on memory of parents',
        joinedDate: DateTime(2020, 8, 5),
        totalDonationsCount: 19,
      ),
      ContributorModel(
        id: 'contributor_5',
        templeId: 'temple_1',
        fullName: 'Dr. Nimal Jayawardena',
        fullNameSi: 'වෛද්‍ය නිමල් ජයවර්ධන මහතා',
        phone: '+94 76 678 9012',
        address: 'No. 104, Hospital Road, Kalubowila',
        familyName: 'Jayawardena Family (ජයවර්ධන පවුල)',
        notes: 'Medical & nutritional alms offerings',
        joinedDate: DateTime(2022, 11, 1),
        totalDonationsCount: 11,
      ),
    ];
  }

  // Seed sample bookings around current date
  static List<AlmsBookingModel> getInitialBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final contributors = getInitialContributors();

    return [
      // Today Morning
      AlmsBookingModel(
        id: 'booking_today_morning',
        templeId: 'temple_1',
        date: today,
        almsType: AlmsType.morning,
        contributorId: contributors[0].id,
        contributorName: contributors[0].fullName,
        contributorNameSi: contributors[0].fullNameSi,
        contributorPhone: contributors[0].phone,
        monksCount: 8,
        specialNotes: 'Herbal porridge (Kenda) + Kiribath with Lunu Miris',
        status: AlmsStatus.assigned,
        isReminderSent: true,
      ),
      // Today Lunch
      AlmsBookingModel(
        id: 'booking_today_lunch',
        templeId: 'temple_1',
        date: today,
        almsType: AlmsType.lunch,
        contributorId: contributors[1].id,
        contributorName: contributors[1].fullName,
        contributorNameSi: contributors[1].fullNameSi,
        contributorPhone: contributors[1].phone,
        monksCount: 8,
        specialNotes: 'Rice, 5 Curries, Curd and Treacle',
        status: AlmsStatus.assigned,
        isReminderSent: true,
      ),
      // Tomorrow Morning (assigned to Sunil Perera - good for previous day notification test)
      AlmsBookingModel(
        id: 'booking_tomorrow_morning',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 1)),
        almsType: AlmsType.morning,
        contributorId: contributors[0].id,
        contributorName: contributors[0].fullName,
        contributorNameSi: contributors[0].fullNameSi,
        contributorPhone: contributors[0].phone,
        monksCount: 8,
        specialNotes: 'Kola Kenda + String Hoppers with Kiri Hodi & Sambol',
        status: AlmsStatus.assigned,
        isReminderSent: false,
      ),
      // Tomorrow Lunch (assigned to Mrs. Malini)
      AlmsBookingModel(
        id: 'booking_tomorrow_lunch',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 1)),
        almsType: AlmsType.lunch,
        contributorId: contributors[1].id,
        contributorName: contributors[1].fullName,
        contributorNameSi: contributors[1].fullNameSi,
        contributorPhone: contributors[1].phone,
        monksCount: 8,
        specialNotes: 'Red Rice, Dhal, Polos Curry, Gotukola Sambol, Watalappan',
        status: AlmsStatus.assigned,
        isReminderSent: false,
      ),
      // Day after tomorrow Morning (Unassigned / Available)
      AlmsBookingModel(
        id: 'booking_day3_morning',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 2)),
        almsType: AlmsType.morning,
        monksCount: 8,
        status: AlmsStatus.available,
      ),
      // Day after tomorrow Lunch (assigned to Chaminda Silva)
      AlmsBookingModel(
        id: 'booking_day3_lunch',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 2)),
        almsType: AlmsType.lunch,
        contributorId: contributors[2].id,
        contributorName: contributors[2].fullName,
        contributorNameSi: contributors[2].fullNameSi,
        contributorPhone: contributors[2].phone,
        monksCount: 8,
        specialNotes: 'Traditional Village Style Dana',
        status: AlmsStatus.assigned,
      ),
      // Day 4 Morning (Assigned to Anula Rathnayake)
      AlmsBookingModel(
        id: 'booking_day4_morning',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 3)),
        almsType: AlmsType.morning,
        contributorId: contributors[3].id,
        contributorName: contributors[3].fullName,
        contributorNameSi: contributors[3].fullNameSi,
        contributorPhone: contributors[3].phone,
        monksCount: 8,
        status: AlmsStatus.assigned,
      ),
      // Day 4 Lunch (Available)
      AlmsBookingModel(
        id: 'booking_day4_lunch',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 3)),
        almsType: AlmsType.lunch,
        monksCount: 8,
        status: AlmsStatus.available,
      ),
      // Day 5 Morning (Available)
      AlmsBookingModel(
        id: 'booking_day5_morning',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 4)),
        almsType: AlmsType.morning,
        monksCount: 8,
        status: AlmsStatus.available,
      ),
      // Day 5 Lunch (Available)
      AlmsBookingModel(
        id: 'booking_day5_lunch',
        templeId: 'temple_1',
        date: today.add(const Duration(days: 4)),
        almsType: AlmsType.lunch,
        monksCount: 8,
        status: AlmsStatus.available,
      ),
    ];
  }

  // Persistence methods
  Future<List<TempleModel>> loadTemples() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyTemples);
    if (data == null) {
      final initial = getInitialTemples();
      await saveTemples(initial);
      return initial;
    }
    final List decoded = jsonDecode(data) as List;
    return decoded.map((e) => TempleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTemples(List<TempleModel> temples) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(temples.map((e) => e.toJson()).toList());
    await prefs.setString(_keyTemples, data);
  }

  Future<List<ContributorModel>> loadContributors() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyContributors);
    if (data == null) {
      final initial = getInitialContributors();
      await saveContributors(initial);
      return initial;
    }
    final List decoded = jsonDecode(data) as List;
    return decoded.map((e) => ContributorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveContributors(List<ContributorModel> contributors) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(contributors.map((e) => e.toJson()).toList());
    await prefs.setString(_keyContributors, data);
  }

  Future<List<AlmsBookingModel>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyBookings);
    if (data == null) {
      final initial = getInitialBookings();
      await saveBookings(initial);
      return initial;
    }
    final List decoded = jsonDecode(data) as List;
    return decoded.map((e) => AlmsBookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBookings(List<AlmsBookingModel> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(bookings.map((e) => e.toJson()).toList());
    await prefs.setString(_keyBookings, data);
  }
}
