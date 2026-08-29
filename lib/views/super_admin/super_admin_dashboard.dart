import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/temple_model.dart';
import '../../providers/alms_provider.dart';
import '../../providers/contributor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../common/language_switcher_button.dart';
import 'widgets/add_edit_temple_modal.dart';

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final templeProvider = context.watch<TempleProvider>();
    final contributorProvider = context.watch<ContributorProvider>();
    final almsProvider = context.watch<AlmsProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final temples = templeProvider.temples;
    final totalContributors = contributorProvider.allContributors.length;
    final totalBookings = almsProvider.allBookings.where((b) => b.isAssigned).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSi ? 'ප්‍රධාන පරිපාලක පුවරුව' : 'Super Admin Dashboard',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSwitcherButton(isCompact: true),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.templeMaroon, AppColors.terracotta],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSi ? 'විහාරස්ථාන පාලන මධ්‍යස්ථානය' : 'Temple Network Administration',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSi
                            ? 'නව පන්සල් සහ නායක ස්වාමීන් වහන්සේලා ලියාපදිංචි කිරීම'
                            : 'Register and manage temples & Chief Monks',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: context.tr('total_temples'),
                  value: '${temples.length}',
                  icon: Icons.temple_buddhist,
                  color: AppColors.saffronPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: context.tr('total_contributors'),
                  value: '$totalContributors',
                  icon: Icons.people_alt,
                  color: AppColors.statusAssigned,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: context.tr('active_alms'),
                  value: '$totalBookings',
                  icon: Icons.volunteer_activism,
                  color: AppColors.terracotta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Temples Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('temples_list'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => AddEditTempleModal.show(context: context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  context.tr('add_temple'),
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Temples List
          ...temples.map((temple) => _buildTempleCard(
                context: context,
                temple: temple,
                isSi: isSi,
                isSelected: temple.id == templeProvider.selectedTempleId,
                onSelect: () => templeProvider.selectTemple(temple.id),
                onEdit: () => AddEditTempleModal.show(context: context, temple: temple),
              )),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleCard({
    required BuildContext context,
    required TempleModel temple,
    required bool isSi,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onEdit,
  }) {
    final templeName = isSi ? temple.nameSi : temple.nameEn;
    final monkName = isSi ? temple.chiefMonkNameSi : temple.chiefMonkName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.saffronPrimary : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.saffronPrimary.withValues(alpha: 0.15),
                  child: const Icon(Icons.temple_buddhist, color: AppColors.saffronDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              templeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.saffronPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isSi ? 'සක්‍රීයයි' : 'Active',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${temple.district} • ${temple.address}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Chief Monk info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.saffronDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('chief_monk'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        monkName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${temple.residentMonksCount} ${isSi ? 'නමක්' : 'Monks'}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 14),
                  label: Text(context.tr('edit'), style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                if (!isSelected)
                  OutlinedButton(
                    onPressed: onSelect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      isSi ? 'මෙම පන්සල තෝරන්න' : 'Select Temple',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
