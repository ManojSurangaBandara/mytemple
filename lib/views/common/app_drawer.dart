import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import 'alms_guidelines_screen.dart';
import 'language_switcher_button.dart';
import 'role_switch_sheet.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;

  const AppDrawer({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeName = isSi
        ? (currentTemple?.nameSi ?? currentTemple?.nameEn ?? 'විහාරස්ථානය')
        : (currentTemple?.nameEn ?? 'Temple');

    return Drawer(
      child: Column(
        children: [
          // Drawer Header with "My Temple" visible title & app icon
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.saffronPrimary, AppColors.saffronDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Temple',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            isSi ? 'අපේ පන්සල • බෞද්ධ විහාරස්ථාන' : 'Buddhist Temple & Alms',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Current Temple & User info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        templeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            isSi ? auth.currentUser.fullNameSi : auth.currentUser.fullName,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              auth.currentUser.roleDisplayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined, color: AppColors.saffronPrimary),
                  title: Text(context.tr('tab_dashboard')),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) onSelectTab!(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: AppColors.saffronPrimary),
                  title: Text(context.tr('tab_calendar')),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) onSelectTab!(1);
                  },
                ),
                if (auth.isTempleAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.people_outline, color: AppColors.saffronPrimary),
                    title: Text(context.tr('tab_contributors')),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(2);
                    },
                  ),
                ] else if (auth.isContributor) ...[
                  ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined, color: AppColors.saffronPrimary),
                    title: Text(context.tr('tab_my_alms')),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(2);
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.temple_buddhist_outlined, color: AppColors.saffronPrimary),
                    title: Text(context.tr('tab_temples')),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(2);
                    },
                  ),
                ],
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined, color: AppColors.saffronPrimary),
                  title: Text(context.tr('alms_guidelines')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlmsGuidelinesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.saffronPrimary),
                  title: Text(context.tr('change_role')),
                  subtitle: Text(
                    auth.currentUser.roleDisplayName,
                    style: const TextStyle(fontSize: 11, color: AppColors.saffronDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    RoleSwitchSheet.show(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.saffronPrimary),
                  title: Text(context.tr('tab_settings')),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) onSelectTab!(3);
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Temple • v1.0.0',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const LanguageSwitcherButton(isCompact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
