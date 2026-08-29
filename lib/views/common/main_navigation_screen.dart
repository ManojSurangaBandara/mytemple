import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../calendar/alms_calendar_screen.dart';
import '../contributor/contributor_dashboard.dart';
import '../contributor/my_alms_screen.dart';
import '../super_admin/super_admin_dashboard.dart';
import '../temple_admin/manage_contributors_screen.dart';
import '../temple_admin/temple_admin_dashboard.dart';
import 'app_drawer.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Dynamic Tab 0 (Dashboard)
    Widget dashboardWidget;
    if (auth.isSuperAdmin) {
      dashboardWidget = const SuperAdminDashboard();
    } else if (auth.isTempleAdmin) {
      dashboardWidget = TempleAdminDashboard(onNavigateTab: _onTabTapped);
    } else {
      dashboardWidget = ContributorDashboard(onNavigateTab: _onTabTapped);
    }

    // Dynamic Tab 2 (Management / My Alms)
    Widget middleWidget;
    String middleTabLabel;
    IconData middleTabIcon;

    if (auth.isSuperAdmin) {
      middleWidget = const SuperAdminDashboard();
      middleTabLabel = context.tr('tab_temples');
      middleTabIcon = Icons.temple_buddhist_outlined;
    } else if (auth.isTempleAdmin) {
      middleWidget = const ManageContributorsScreen();
      middleTabLabel = context.tr('tab_contributors');
      middleTabIcon = Icons.people_outline;
    } else {
      middleWidget = const MyAlmsScreen();
      middleTabLabel = context.tr('tab_my_alms');
      middleTabIcon = Icons.volunteer_activism_outlined;
    }

    final pages = [
      dashboardWidget, // Tab 0: Role Dashboard (Left-most)
      const AlmsCalendarScreen(), // Tab 1: Alms Calendar
      middleWidget, // Tab 2: Contributors / Temples / My Alms
      const SettingsScreen(), // Tab 3: Settings & Role Switcher
    ];

    return Scaffold(
      drawer: AppDrawer(onSelectTab: _onTabTapped),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.saffronPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: context.tr('tab_dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: context.tr('tab_calendar'),
          ),
          BottomNavigationBarItem(
            icon: Icon(middleTabIcon),
            label: middleTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: context.tr('tab_settings'),
          ),
        ],
      ),
    );
  }
}
