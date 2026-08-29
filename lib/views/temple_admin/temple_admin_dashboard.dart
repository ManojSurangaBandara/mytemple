import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/alms_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contributor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../calendar/widgets/alms_slot_card.dart';
import '../common/alms_guidelines_screen.dart';
import '../common/language_switcher_button.dart';
import '../common/role_switch_sheet.dart';
import 'widgets/add_edit_contributor_modal.dart';

class TempleAdminDashboard extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const TempleAdminDashboard({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final contributorProvider = context.watch<ContributorProvider>();
    final almsProvider = context.watch<AlmsProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeId = currentTemple?.id ?? 'temple_1';
    final templeName = isSi
        ? (currentTemple?.nameSi ?? currentTemple?.nameEn ?? 'විහාරස්ථානය')
        : (currentTemple?.nameEn ?? 'Temple');

    final contributors = contributorProvider.getContributorsForTemple(templeId);
    final today = DateTime.now();
    final todaySlots = almsProvider.getSlotsForDate(
      templeId: templeId,
      date: today,
      defaultMonksCount: currentTemple?.residentMonksCount ?? 5,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSi ? 'නායක හිමි පරිපාලන පුවරුව' : 'Chief Monk Dashboard',
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
          // Chief Monk Welcome Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.saffronPrimary, AppColors.saffronDark],
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
                  child: const Icon(Icons.temple_buddhist, color: Colors.white, size: 28),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${currentTemple?.residentMonksCount ?? 5} ${isSi ? 'නමක සංඝරත්නය' : 'Resident Monks'}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Summary Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: context.tr('contributors'),
                  subtitle: '${contributors.length} ${isSi ? 'දෙනෙක්' : 'Members'}',
                  icon: Icons.people,
                  color: AppColors.statusAssigned,
                  onTap: () {
                    if (onNavigateTab != null) onNavigateTab!(2);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: context.tr('tab_calendar'),
                  subtitle: isSi ? 'දාන වාර කළමනාකරණය' : 'Manage Dāna Slots',
                  icon: Icons.calendar_month,
                  color: AppColors.saffronPrimary,
                  onTap: () {
                    if (onNavigateTab != null) onNavigateTab!(1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Alms Status Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.today, size: 20, color: AppColors.saffronPrimary),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('today_alms'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM d, yyyy').format(today),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Today's slot cards (Morning & Lunch)
          ...todaySlots.map((slot) => AlmsSlotCard(
                slot: slot,
                templeId: templeId,
              )),

          const SizedBox(height: 16),

          // Quick Management Actions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSi ? 'ක්ෂණික ක්‍රියාමාර්ග' : 'Quick Actions',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.person_add, size: 16, color: AppColors.saffronDark),
                        label: Text(context.tr('add_contributor')),
                        onPressed: () => AddEditContributorModal.show(
                          context: context,
                          templeId: templeId,
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.menu_book, size: 16, color: AppColors.saffronDark),
                        label: Text(context.tr('alms_guidelines')),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AlmsGuidelinesScreen()),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.swap_horiz, size: 16, color: AppColors.saffronDark),
                        label: Text(context.tr('change_role')),
                        onPressed: () => RoleSwitchSheet.show(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
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
