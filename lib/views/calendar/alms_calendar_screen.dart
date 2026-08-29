import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/alms_booking_model.dart';
import '../../providers/alms_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/temple_provider.dart';
import '../common/language_switcher_button.dart';
import 'widgets/alms_filter_bar.dart';
import 'widgets/alms_slot_card.dart';

class AlmsCalendarScreen extends StatefulWidget {
  const AlmsCalendarScreen({super.key});

  @override
  State<AlmsCalendarScreen> createState() => _AlmsCalendarScreenState();
}

class _AlmsCalendarScreenState extends State<AlmsCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final alms = context.watch<AlmsProvider>();
    final templeProvider = context.watch<TempleProvider>();
    final auth = context.watch<AuthProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    final currentTemple = templeProvider.currentTemple;
    final templeId = currentTemple?.id ?? 'temple_1';
    final templeName = isSi
        ? (currentTemple?.nameSi ?? currentTemple?.nameEn ?? 'විහාරස්ථානය')
        : (currentTemple?.nameEn ?? 'Temple');

    final residentMonks = currentTemple?.residentMonksCount ?? 5;
    final slotsForSelectedDay = alms.getFilteredSlotsForDate(
      templeId: templeId,
      date: alms.selectedDate,
      currentContributorId: auth.activeContributorId,
      defaultMonksCount: residentMonks,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('tab_calendar'),
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
      body: Column(
        children: [
          // Filter bar
          const AlmsFilterBar(),

          // Calendar & Agenda
          Expanded(
            child: ListView(
              children: [
                // Calendar Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TableCalendar<AlmsBookingModel>(
                      firstDay: DateTime.utc(2025, 1, 1),
                      lastDay: DateTime.utc(2028, 12, 31),
                      focusedDay: alms.focusedMonth,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(alms.selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        alms.setSelectedDate(selectedDay);
                        alms.setFocusedMonth(focusedDay);
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        alms.setFocusedMonth(focusedDay);
                      },
                      eventLoader: (day) => alms.getEventsForDay(day, templeId),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        formatButtonShowsNext: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        formatButtonDecoration: BoxDecoration(
                          color: AppColors.saffronPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        formatButtonTextStyle: const TextStyle(
                          color: AppColors.saffronDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.saffronPrimary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.saffronLight.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.statusAssigned,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final summary = alms.getDayStatusSummary(date, templeId);
                          final hasMorning = summary['hasMorning'] as bool;
                          final hasLunch = summary['hasLunch'] as bool;

                          if (!hasMorning && !hasLunch) return null;

                          return Positioned(
                            bottom: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasMorning)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: const BoxDecoration(
                                      color: AppColors.morningAlms,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasLunch)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: const BoxDecoration(
                                      color: AppColors.lunchAlms,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Calendar Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: AppColors.morningAlms,
                        label: isSi ? 'හීල් දානය (🌅)' : 'Morning (🌅)',
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        color: AppColors.lunchAlms,
                        label: isSi ? 'දිවා දානය (☀️)' : 'Lunch (☀️)',
                      ),
                    ],
                  ),
                ),

                // Selected Day Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 20, color: AppColors.saffronPrimary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(alms.selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // Slots Cards for Morning and Lunch
                if (slotsForSelectedDay.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        context.tr('no_data'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ] else ...[
                  ...slotsForSelectedDay.map((slot) => AlmsSlotCard(
                        slot: slot,
                        templeId: templeId,
                      )),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
