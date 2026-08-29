import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytemple/core/localization/app_localizations.dart';
import 'package:mytemple/core/services/notification_service.dart';
import 'package:mytemple/main.dart';
import 'package:mytemple/models/alms_booking_model.dart';
import 'package:mytemple/models/user_model.dart';
import 'package:mytemple/providers/alms_provider.dart';
import 'package:mytemple/providers/auth_provider.dart';
import 'package:mytemple/providers/contributor_provider.dart';
import 'package:mytemple/providers/language_provider.dart';
import 'package:mytemple/providers/temple_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AlmsBookingModel slot key generation & morning/lunch types', () {
    final date = DateTime(2026, 8, 30);
    final morningSlot = AlmsBookingModel(
      id: 'test_morning',
      templeId: 'temple_1',
      date: date,
      almsType: AlmsType.morning,
      monksCount: 8,
    );

    final lunchSlot = AlmsBookingModel(
      id: 'test_lunch',
      templeId: 'temple_1',
      date: date,
      almsType: AlmsType.lunch,
      monksCount: 8,
    );

    expect(morningSlot.isMorning, isTrue);
    expect(morningSlot.isLunch, isFalse);
    expect(morningSlot.slotKey, equals('2026-08-30_morning'));

    expect(lunchSlot.isMorning, isFalse);
    expect(lunchSlot.isLunch, isTrue);
    expect(lunchSlot.slotKey, equals('2026-08-30_lunch'));
  });

  test('UserModel role hierarchy and permissions', () {
    const superAdmin = UserModel(
      id: 'admin_1',
      fullName: 'Super Admin',
      fullNameSi: 'ප්‍රධාන පරිපාලක',
      phone: '+94 77 111 2222',
      email: 'admin@mytemple.lk',
      role: UserRole.superAdmin,
    );

    const monk = UserModel(
      id: 'monk_1',
      fullName: 'Ven. Dhammarathana Thero',
      fullNameSi: 'පූජ්‍ය ධම්මරතන හිමි',
      phone: '+94 77 333 4444',
      email: 'monk@mytemple.lk',
      role: UserRole.templeAdmin,
      assignedTempleId: 'temple_1',
    );

    const contributor = UserModel(
      id: 'contributor_1',
      fullName: 'Sunil Perera',
      fullNameSi: 'සුනිල් පෙරේරා',
      phone: '+94 71 555 6666',
      email: 'sunil@gmail.com',
      role: UserRole.contributor,
      contributorId: 'c_1',
    );

    expect(superAdmin.isSuperAdmin, isTrue);
    expect(superAdmin.isTempleAdmin, isFalse);

    expect(monk.isTempleAdmin, isTrue);
    expect(monk.isSuperAdmin, isFalse);

    expect(contributor.isContributor, isTrue);
    expect(contributor.isTempleAdmin, isFalse);
  });

  test('AppLocalizations translation lookups in English & Sinhala', () {
    final enL10n = AppLocalizations(const Locale('en'));
    final siL10n = AppLocalizations(const Locale('si'));

    expect(enL10n.translate('morning_alms'), contains('Morning Alms'));
    expect(siL10n.translate('morning_alms'), contains('හීල් දානය'));

    expect(enL10n.translate('lunch_alms'), contains('Lunch Alms'));
    expect(siL10n.translate('lunch_alms'), contains('දිවා දානය'));

    final paramText = siL10n.translate(
      'notification_body_morning',
      params: {'count': '5', 'temple': 'බෙල්ලන්විල'},
    );
    expect(paramText, contains('බෙල්ලන්විල'));
    expect(paramText, contains('5'));
  });

  test('NotificationService previous-day reminder calculation', () {
    final service = NotificationService();
    final almsDate = DateTime(2026, 9, 15, 6, 30);
    final reminderTime = service.getPreviousDayReminderTime(almsDate, hour: 18, minute: 0);

    expect(reminderTime.year, equals(2026));
    expect(reminderTime.month, equals(9));
    expect(reminderTime.day, equals(14));
    expect(reminderTime.hour, equals(18));
    expect(reminderTime.minute, equals(0));
  });

  test('AlmsProvider slot retrieval for date produces both morning and lunch slots', () {
    final provider = AlmsProvider();
    final date = DateTime(2026, 10, 10);
    final slots = provider.getSlotsForDate(
      templeId: 'temple_1',
      date: date,
      defaultMonksCount: 8,
    );

    expect(slots.length, equals(2));
    expect(slots.any((s) => s.isMorning), isTrue);
    expect(slots.any((s) => s.isLunch), isTrue);
  });

  test('ContributorProvider search filters by name and phone', () async {
    final provider = ContributorProvider();
    await provider.loadContributors();

    provider.setSearchQuery('Sunil');
    final results = provider.getContributorsForTemple('temple_1');
    expect(results.any((c) => c.fullName.contains('Sunil')), isTrue);
  });

  testWidgets('MyTempleApp smoke test & main navigation render',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TempleProvider()),
          ChangeNotifierProvider(create: (_) => ContributorProvider()),
          ChangeNotifierProvider(create: (_) => AlmsProvider()),
        ],
        child: const MyTempleApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab bar elements
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
  });
}
