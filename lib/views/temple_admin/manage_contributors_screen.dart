import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/contributor_model.dart';
import '../../providers/contributor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../common/language_switcher_button.dart';
import 'widgets/add_edit_contributor_modal.dart';

class ManageContributorsScreen extends StatefulWidget {
  const ManageContributorsScreen({super.key});

  @override
  State<ManageContributorsScreen> createState() =>
      _ManageContributorsScreenState();
}

class _ManageContributorsScreenState extends State<ManageContributorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templeProvider = context.watch<TempleProvider>();
    final contributorProvider = context.watch<ContributorProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeId = currentTemple?.id ?? 'temple_1';
    final contributors = contributorProvider.getContributorsForTemple(templeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('contributors'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSwitcherButton(isCompact: true),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Count Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.tr('search_contributor'),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          contributorProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => contributorProvider.setSearchQuery(val),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${contributors.length} ${isSi ? 'දෙනෙකු ලියාපදිංචි වී ඇත' : 'registered contributors'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => AddEditContributorModal.show(
                    context: context,
                    templeId: templeId,
                  ),
                  icon: const Icon(Icons.person_add_alt_1, size: 16),
                  label: Text(
                    context.tr('add_contributor'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Contributors List
          Expanded(
            child: contributors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('no_data'),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => AddEditContributorModal.show(
                            context: context,
                            templeId: templeId,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(context.tr('add_contributor')),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: contributors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final contributor = contributors[index];
                      return _buildContributorCard(
                        context: context,
                        contributor: contributor,
                        isSi: isSi,
                        templeId: templeId,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditContributorModal.show(
          context: context,
          templeId: templeId,
        ),
        backgroundColor: AppColors.saffronPrimary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          context.tr('add_contributor'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContributorCard({
    required BuildContext context,
    required ContributorModel contributor,
    required bool isSi,
    required String templeId,
  }) {
    final name = isSi ? contributor.fullNameSi : contributor.fullName;

    return Card(
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
                  child: Text(
                    contributor.fullName.isNotEmpty
                        ? contributor.fullName[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                      color: AppColors.saffronDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (contributor.familyName != null &&
                          contributor.familyName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          contributor.familyName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.saffronDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            contributor.phone,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      if (contributor.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                contributor.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Total Donations Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusAssignedBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.statusAssigned.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${contributor.totalDonationsCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusAssigned,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        isSi ? 'දාන වාර' : 'Donations',
                        style: const TextStyle(
                          color: AppColors.statusAssigned,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (contributor.notes != null && contributor.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  contributor.notes!,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.tr('joined_date')}: ${DateFormat('yyyy-MM-dd').format(contributor.joinedDate)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: context.tr('edit'),
                      onPressed: () => AddEditContributorModal.show(
                        context: context,
                        templeId: templeId,
                        contributor: contributor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      tooltip: context.tr('delete'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(context.tr('confirm_delete')),
                            content: Text(
                                '${context.tr('delete')} $name?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(context.tr('cancel')),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(context.tr('delete')),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await Provider.of<ContributorProvider>(context, listen: false)
                              .deleteContributor(contributor.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
