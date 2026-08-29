import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/alms_booking_model.dart';
import '../../../providers/alms_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/temple_provider.dart';
import 'assign_alms_modal.dart';

class AlmsSlotCard extends StatelessWidget {
  final AlmsBookingModel slot;
  final String templeId;

  const AlmsSlotCard({
    super.key,
    required this.slot,
    required this.templeId,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;
    final temple = context.watch<TempleProvider>().currentTemple;

    final isMorning = slot.isMorning;
    final isAssigned = slot.isAssigned;
    final isMyBooking = auth.isContributor && auth.activeContributorId == slot.contributorId;

    final Color accentColor = isMorning ? AppColors.morningAlms : AppColors.lunchAlms;
    final Color bgColor = isMorning ? AppColors.morningAlmsBg : AppColors.lunchAlmsBg;

    final String slotName = isMorning
        ? context.tr('morning_alms')
        : context.tr('lunch_alms');
    final String slotTime = isMorning
        ? context.tr('morning_alms_time')
        : context.tr('lunch_alms_time');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isMyBooking
              ? AppColors.statusMyBooking
              : isAssigned
                  ? accentColor.withValues(alpha: 0.4)
                  : AppColors.borderLight,
          width: isMyBooking ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Slot Icon, Slot Name, Time, Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    isMorning ? Icons.wb_sunny_outlined : Icons.wb_sunny,
                    color: accentColor,
                    size: 24,
                  ),
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
                              slotName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildStatusBadge(
                            context: context,
                            isAssigned: isAssigned,
                            isMyBooking: isMyBooking,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 13, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            slotTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
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

            // Middle: Details depending on assigned or available
            if (isAssigned) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: accentColor.withValues(alpha: 0.15),
                    child: Icon(Icons.person, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('assigned_to'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          isSi
                              ? (slot.contributorNameSi ?? slot.contributorName ?? '')
                              : (slot.contributorName ?? ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (slot.contributorPhone != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                slot.contributorPhone!,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Monks count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.saffronPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${slot.monksCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.saffronDark,
                          ),
                        ),
                        Text(
                          isSi ? 'නමකට' : 'Monks',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.saffronDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (slot.specialNotes != null && slot.specialNotes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          slot.specialNotes!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Available Slot banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusAvailableBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.statusAvailable.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.statusAvailable, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isSi
                            ? 'මෙම දාන වාරය තවමත් කිසිදු දායකයෙකුට භාරදී නොමැත.'
                            : 'This alms slot is currently available and open for donation.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.saffronDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Bottom Actions: Chief Monk can Assign/Reassign, Test notification trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Test Notification Trigger (Helpful for demoing the previous-day notification feature)
                if (isAssigned) ...[
                  TextButton.icon(
                    onPressed: () async {
                      final templeName = isSi
                          ? (temple?.nameSi ?? temple?.nameEn ?? 'විහාරස්ථානය')
                          : (temple?.nameEn ?? 'Temple');

                      await Provider.of<AlmsProvider>(context, listen: false)
                          .triggerInstantReminder(
                        booking: slot,
                        templeName: templeName,
                        isSinhala: isSi,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.notifications_active, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(context.tr('notification_sent')),
                              ],
                            ),
                            backgroundColor: AppColors.statusAssigned,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_outlined, size: 16),
                    label: Text(
                      context.tr('send_test_notification'),
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.saffronDark,
                    ),
                  ),
                  const Spacer(),
                ],

                // Action button depending on role
                if (auth.isTempleAdmin || auth.isSuperAdmin) ...[
                  OutlinedButton.icon(
                    onPressed: () => AssignAlmsModal.show(
                      context: context,
                      slot: slot,
                      templeId: templeId,
                    ),
                    icon: Icon(
                      isAssigned ? Icons.edit : Icons.person_add_alt_1,
                      size: 16,
                    ),
                    label: Text(
                      isAssigned
                          ? context.tr('reassign_alms')
                          : context.tr('assign_alms'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ] else if (auth.isContributor && !isAssigned) ...[
                  ElevatedButton.icon(
                    onPressed: () => AssignAlmsModal.show(
                      context: context,
                      slot: slot,
                      templeId: templeId,
                    ),
                    icon: const Icon(Icons.volunteer_activism, size: 16),
                    label: Text(
                      isSi ? 'දානය භාරගන්න' : 'Offer Dāna',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required BuildContext context,
    required bool isAssigned,
    required bool isMyBooking,
  }) {
    if (isMyBooking) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusMyBookingBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.statusMyBooking.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppColors.statusMyBooking, size: 12),
            const SizedBox(width: 4),
            Text(
              context.tr('slot_my_booking'),
              style: const TextStyle(
                color: AppColors.statusMyBooking,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (isAssigned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusAssignedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.statusAssigned.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.statusAssigned, size: 12),
            const SizedBox(width: 4),
            Text(
              context.tr('slot_assigned'),
              style: const TextStyle(
                color: AppColors.statusAssigned,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusAvailableBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.statusAvailable.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle_outlined, color: AppColors.statusAvailable, size: 12),
          const SizedBox(width: 4),
          Text(
            context.tr('slot_available'),
            style: const TextStyle(
              color: AppColors.statusAvailable,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
