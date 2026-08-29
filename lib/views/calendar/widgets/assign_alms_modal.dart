import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/alms_booking_model.dart';
import '../../../models/contributor_model.dart';
import '../../../providers/alms_provider.dart';
import '../../../providers/contributor_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/temple_provider.dart';
import '../../temple_admin/widgets/add_edit_contributor_modal.dart';

class AssignAlmsModal extends StatefulWidget {
  final AlmsBookingModel slot;
  final String templeId;

  const AssignAlmsModal({
    super.key,
    required this.slot,
    required this.templeId,
  });

  static Future<bool?> show({
    required BuildContext context,
    required AlmsBookingModel slot,
    required String templeId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignAlmsModal(
        slot: slot,
        templeId: templeId,
      ),
    );
  }

  @override
  State<AssignAlmsModal> createState() => _AssignAlmsModalState();
}

class _AssignAlmsModalState extends State<AssignAlmsModal> {
  ContributorModel? _selectedContributor;
  late int _monksCount;
  late TextEditingController _notesController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _monksCount = widget.slot.monksCount;
    _notesController = TextEditingController(text: widget.slot.specialNotes ?? '');

    // If already assigned, pre-select
    if (widget.slot.contributorId != null) {
      final contributors = Provider.of<ContributorProvider>(context, listen: false)
          .getContributorsForTemple(widget.templeId);
      try {
        _selectedContributor = contributors.firstWhere((c) => c.id == widget.slot.contributorId);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSi = context.watch<LanguageProvider>().isSinhala;
    final temple = context.watch<TempleProvider>().currentTemple;
    final contributorProvider = context.watch<ContributorProvider>();
    final contributors = contributorProvider.getContributorsForTemple(widget.templeId);

    final filteredContributors = _searchQuery.trim().isEmpty
        ? contributors
        : contributors.where((c) =>
            c.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.fullNameSi.contains(_searchQuery) ||
            c.phone.contains(_searchQuery)).toList();

    final isMorning = widget.slot.isMorning;
    final slotTitle = isMorning
        ? context.tr('morning_alms')
        : context.tr('lunch_alms');
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(widget.slot.date);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMorning
                      ? AppColors.morningAlms.withValues(alpha: 0.15)
                      : AppColors.lunchAlms.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMorning ? Icons.wb_sunny_outlined : Icons.wb_sunny,
                  color: isMorning ? AppColors.morningAlms : AppColors.lunchAlms,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.slot.isAssigned
                          ? context.tr('reassign_alms')
                          : context.tr('assign_alms'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$slotTitle • $formattedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: isMorning ? AppColors.morningAlms : AppColors.lunchAlms,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          Expanded(
            child: ListView(
              children: [
                // Sangha / Monks count selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('monks_count'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _monksCount > 1
                              ? () => setState(() => _monksCount--)
                              : null,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_monksCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.saffronDark,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _monksCount++),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Contributor Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('select_contributor'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_alt_1, size: 16),
                      label: Text(
                        context.tr('quick_add_contributor'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        final newContributor = await AddEditContributorModal.show(
                          context: context,
                          templeId: widget.templeId,
                        );
                        if (newContributor != null) {
                          setState(() {
                            _selectedContributor = newContributor;
                          });
                        }
                      },
                    ),
                  ],
                ),

                // Search field for contributors
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.tr('search_contributor'),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),

                // Contributors list
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: filteredContributors.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context.tr('no_data'),
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredContributors.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final contributor = filteredContributors[index];
                            final isSelected = _selectedContributor?.id == contributor.id;

                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              selectedTileColor: AppColors.saffronPrimary.withValues(alpha: 0.1),
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: isSelected
                                    ? AppColors.saffronPrimary
                                    : Colors.grey.withValues(alpha: 0.2),
                                child: Text(
                                  contributor.fullName.isNotEmpty
                                      ? contributor.fullName[0].toUpperCase()
                                      : 'D',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                isSi ? contributor.fullNameSi : contributor.fullName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                contributor.phone,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.saffronPrimary, size: 20)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedContributor = contributor;
                                });
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),

                // Special Notes / Instructions
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr('notes'),
                    hintText: isSi
                        ? 'උදා: කිරිබත්, පරිප්පු, අතුරුපස සහ පලතුරු'
                        : 'e.g. Kola Kenda, Kiribath, Fruits, Dessert',
                  ),
                ),
                const SizedBox(height: 12),

                // Previous day notification reminder badge notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusAssigned.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.statusAssigned.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          color: AppColors.statusAssigned, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('reminder_description'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.statusAssigned,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (widget.slot.isAssigned) ...[
                OutlinedButton(
                  onPressed: () async {
                    await Provider.of<AlmsProvider>(context, listen: false).unassignAlmsSlot(
                      templeId: widget.templeId,
                      date: widget.slot.date,
                      almsType: widget.slot.almsType,
                    );
                    if (context.mounted) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('booking_removed'))),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  child: Text(context.tr('unassign_alms')),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedContributor == null
                      ? null
                      : () async {
                          final templeName = isSi
                              ? (temple?.nameSi ?? temple?.nameEn ?? 'විහාරස්ථානය')
                              : (temple?.nameEn ?? 'Temple');

                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final contributorProvider =
                              Provider.of<ContributorProvider>(context, listen: false);
                          final almsProvider =
                              Provider.of<AlmsProvider>(context, listen: false);
                          final successMessage = context.tr('booking_success');

                          await almsProvider.assignAlmsSlot(
                            templeId: widget.templeId,
                            date: widget.slot.date,
                            almsType: widget.slot.almsType,
                            contributor: _selectedContributor!,
                            monksCount: _monksCount,
                            specialNotes: _notesController.text.trim().isEmpty
                                ? null
                                : _notesController.text.trim(),
                            templeName: templeName,
                            isSinhala: isSi,
                          );

                          // Increment donation count for contributor
                          await contributorProvider
                              .incrementDonationCount(_selectedContributor!.id);

                          navigator.pop(true);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(successMessage),
                              backgroundColor: AppColors.statusAssigned,
                            ),
                          );
                        },
                  child: Text(context.tr('confirm')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
