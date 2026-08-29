import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/alms_provider.dart';

class AlmsFilterBar extends StatelessWidget {
  const AlmsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final alms = context.watch<AlmsProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Slot type filters
          _buildFilterChip(
            context: context,
            label: context.tr('all'),
            isSelected: alms.filterType == AlmsFilterType.all && alms.filterStatus == AlmsFilterStatus.all,
            onSelected: () {
              alms.setFilterType(AlmsFilterType.all);
              alms.setFilterStatus(AlmsFilterStatus.all);
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '🌅 ${context.tr('morning_alms_short')}',
            isSelected: alms.filterType == AlmsFilterType.morningOnly,
            onSelected: () {
              alms.setFilterType(
                alms.filterType == AlmsFilterType.morningOnly
                    ? AlmsFilterType.all
                    : AlmsFilterType.morningOnly,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '☀️ ${context.tr('lunch_alms_short')}',
            isSelected: alms.filterType == AlmsFilterType.lunchOnly,
            onSelected: () {
              alms.setFilterType(
                alms.filterType == AlmsFilterType.lunchOnly
                    ? AlmsFilterType.all
                    : AlmsFilterType.lunchOnly,
              );
            },
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: AppColors.borderLight),
          const SizedBox(width: 8),
          // Status filters
          _buildFilterChip(
            context: context,
            label: '🟢 ${context.tr('slot_assigned')}',
            isSelected: alms.filterStatus == AlmsFilterStatus.assignedOnly,
            onSelected: () {
              alms.setFilterStatus(
                alms.filterStatus == AlmsFilterStatus.assignedOnly
                    ? AlmsFilterStatus.all
                    : AlmsFilterStatus.assignedOnly,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '🟡 ${context.tr('slot_available')}',
            isSelected: alms.filterStatus == AlmsFilterStatus.availableOnly,
            onSelected: () {
              alms.setFilterStatus(
                alms.filterStatus == AlmsFilterStatus.availableOnly
                    ? AlmsFilterStatus.all
                    : AlmsFilterStatus.availableOnly,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.saffronPrimary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.saffronDark,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.saffronDark : AppColors.textPrimary,
      ),
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.saffronPrimary : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
