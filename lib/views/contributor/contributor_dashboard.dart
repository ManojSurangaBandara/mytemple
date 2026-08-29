import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/alms_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../common/alms_guidelines_screen.dart';
import '../common/language_switcher_button.dart';
import '../common/role_switch_sheet.dart';

class ContributorDashboard extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const ContributorDashboard({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final almsProvider = context.watch<AlmsProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeId = currentTemple?.id ?? 'temple_1';
    final templeName = isSi
        ? (currentTemple?.nameSi ?? currentTemple?.nameEn ?? 'විහාරස්ථානය')
        : (currentTemple?.nameEn ?? 'Temple');

    final myUpcomingAlms = almsProvider.getMyUpcomingAlms(
      contributorId: auth.activeContributorId ?? 'contributor_1',
      templeId: templeId,
    );

    final nextBooking = myUpcomingAlms.isNotEmpty ? myUpcomingAlms.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('tab_dashboard'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              templeName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.saffronDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: const [
          LanguageSwitcherButton(isCompact: true),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.saffronPrimary, AppColors.terracotta],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSi ? 'තෙරුවන් සරණයි!' : 'Theruwan Saranai!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSi ? auth.currentUser.fullNameSi : auth.currentUser.fullName,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        templeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Next Assigned Alms Highlight
          Text(
            isSi ? 'ඔබගේ ඊළඟ දානමය වාරය' : 'Your Next Alms Donation',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          if (nextBooking != null) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.saffronPrimary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: nextBooking.isMorning
                                ? AppColors.morningAlmsBg
                                : AppColors.lunchAlmsBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            nextBooking.isMorning ? Icons.wb_sunny_outlined : Icons.wb_sunny,
                            color: nextBooking.isMorning
                                ? AppColors.morningAlms
                                : AppColors.lunchAlms,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextBooking.isMorning
                                    ? context.tr('morning_alms')
                                    : context.tr('lunch_alms'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(nextBooking.date),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.saffronDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          '${nextBooking.monksCount} ${isSi ? 'නමක මහා සංඝරත්නය උදෙසා' : 'Monks'}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          nextBooking.isMorning
                              ? context.tr('morning_alms_time')
                              : context.tr('lunch_alms_time'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (nextBooking.specialNotes != null && nextBooking.specialNotes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${context.tr('notes')}: ${nextBooking.specialNotes}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Previous day notification banner
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.statusAssigned.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: AppColors.statusAssigned, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isSi
                                  ? 'පෙරදින සවස 6:00 ට ඔබට ස්වයංක්‍රීය මතක්කිරීමක් ලැබෙනු ඇත.'
                                  : 'Automated notification reminder will be sent 1 day prior at 6:00 PM.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.statusAssigned,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('no_assigned_alms'),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (onNavigateTab != null) onNavigateTab!(0);
                      },
                      child: Text(
                        isSi ? 'දාන දිනදර්ශනය බලන්න' : 'View Alms Calendar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Action Grid
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  context: context,
                  title: context.tr('tab_calendar'),
                  subtitle: isSi ? 'සියලු දාන වාර' : 'All Dāna Slots',
                  icon: Icons.calendar_month,
                  color: AppColors.saffronPrimary,
                  onTap: () {
                    if (onNavigateTab != null) onNavigateTab!(0);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTile(
                  context: context,
                  title: context.tr('alms_guidelines'),
                  subtitle: isSi ? 'පිළිවෙත් සහ වේලාවන්' : 'Etiquette & Timings',
                  icon: Icons.menu_book,
                  color: AppColors.terracotta,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlmsGuidelinesScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Role switcher chip
          Center(
            child: ActionChip(
              avatar: const Icon(Icons.swap_horiz, size: 16, color: AppColors.saffronDark),
              label: Text(context.tr('change_role')),
              onPressed: () => RoleSwitchSheet.show(context),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
