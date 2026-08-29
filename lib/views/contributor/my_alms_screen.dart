import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/alms_booking_model.dart';
import '../../providers/alms_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../common/language_switcher_button.dart';

class MyAlmsScreen extends StatelessWidget {
  const MyAlmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final almsProvider = context.watch<AlmsProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeId = currentTemple?.id ?? 'temple_1';

    final myAlms = almsProvider.getMyUpcomingAlms(
      contributorId: auth.activeContributorId ?? 'contributor_1',
      templeId: templeId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('tab_my_alms'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSwitcherButton(isCompact: true),
          SizedBox(width: 12),
        ],
      ),
      body: myAlms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('no_assigned_alms'),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myAlms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = myAlms[index];
                return _buildBookingCard(context, booking, isSi);
              },
            ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, AlmsBookingModel booking, bool isSi) {
    final isMorning = booking.isMorning;
    final slotName = isMorning
        ? context.tr('morning_alms')
        : context.tr('lunch_alms');
    final time = isMorning
        ? context.tr('morning_alms_time')
        : context.tr('lunch_alms_time');
    final accentColor = isMorning ? AppColors.morningAlms : AppColors.lunchAlms;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
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
                    color: isMorning
                        ? AppColors.morningAlmsBg
                        : AppColors.lunchAlmsBg,
                    borderRadius: BorderRadius.circular(12),
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
                      Text(
                        slotName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(booking.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: accentColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.monksCount} ${isSi ? 'නමකට' : 'Monks'}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            if (booking.specialNotes != null && booking.specialNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${context.tr('notes')}: ${booking.specialNotes}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusAssigned.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, size: 14, color: AppColors.statusAssigned),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('notification_scheduled'),
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
    );
  }
}
