import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import 'alms_guidelines_screen.dart';
import 'language_switcher_button.dart';
import 'role_switch_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final isSi = langProvider.isSinhala;

    final currentTemple = templeProvider.currentTemple;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('tab_settings'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.saffronPrimary.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.saffronDark, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSi ? auth.currentUser.fullNameSi : auth.currentUser.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.saffronPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.currentUser.roleDisplayName,
                            style: const TextStyle(
                              color: AppColors.saffronDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.currentUser.phone,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: AppColors.saffronPrimary),
                    tooltip: context.tr('change_role'),
                    onPressed: () => RoleSwitchSheet.show(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Role Switcher Tile
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.saffronPrimary),
              title: Text(context.tr('change_role')),
              subtitle: Text(
                isSi
                    ? 'Super Admin, නායක හිමි, දායකයා භූමිකාවන් අතර මාරු වන්න'
                    : 'Switch between Super Admin, Chief Monk, and Contributor',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => RoleSwitchSheet.show(context),
            ),
          ),
          const SizedBox(height: 10),

          // Language Setting Tile
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppColors.saffronPrimary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('language'),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            isSi ? 'සිංහල (Sinhala)' : 'English',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const LanguageSwitcherButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Active Temple Selector (if multiple temples exist)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.temple_buddhist_outlined, color: AppColors.saffronPrimary),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('select_temple'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: currentTemple?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: templeProvider.temples.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          isSi ? t.nameSi : t.nameEn,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) templeProvider.selectTemple(val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Guidelines Tile
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined, color: AppColors.saffronPrimary),
              title: Text(context.tr('alms_guidelines')),
              subtitle: Text(
                context.tr('alms_guidelines_subtitle'),
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlmsGuidelinesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Test Notification Trigger
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: AppColors.statusAssigned),
              title: Text(context.tr('send_test_notification')),
              subtitle: Text(
                isSi
                    ? 'පෙරදින දැනුම්දීමේ පණිවිඩය පරීක්ෂා කරන්න'
                    : 'Send instant notification to test reminder system',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.send, size: 18, color: AppColors.statusAssigned),
              onTap: () async {
                final templeName = isSi
                    ? (currentTemple?.nameSi ?? currentTemple?.nameEn ?? 'බෙල්ලන්විල රජමහා විහාරය')
                    : (currentTemple?.nameEn ?? 'Bellanwila Rajamaha Viharaya');

                await NotificationService().showInstantNotification(
                  id: 999,
                  title: isSi
                      ? 'මතක්කිරීම: හෙට දින හීල් දානය සඳහා ඔබගේ වාරයයි'
                      : 'Reminder: Tomorrow Morning Alms (Heel Dāna)',
                  body: isSi
                      ? '$templeName විහාරස්ථානයේ සංඝරත්නය 8 නමක් උදෙසා හෙට හීල් දානය පිළියෙළ කිරීමට කාරුණික වන්න.'
                      : 'Tomorrow is your turn to provide Morning Alms for 8 monks at $templeName.',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('notification_sent')),
                      backgroundColor: AppColors.statusAssigned,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // App Footer with App Icon
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${context.tr('app_title')} • v1.0.0',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSi ? 'ශ්‍රී ලාංකික බෞද්ධ විහාරස්ථාන සඳහා' : 'For Sri Lankan Buddhist Temples',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
