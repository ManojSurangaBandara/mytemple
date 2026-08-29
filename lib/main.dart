import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/alms_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/contributor_provider.dart';
import 'providers/language_provider.dart';
import 'providers/temple_provider.dart';
import 'views/common/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service for previous-day reminders
  await NotificationService().initialize();

  runApp(
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
}

class MyTempleApp extends StatelessWidget {
  const MyTempleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'My Temple - අපේ පන්සල',
      debugShowCheckedModeBanner: false,
      locale: languageProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainNavigationScreen(),
    );
  }
}
