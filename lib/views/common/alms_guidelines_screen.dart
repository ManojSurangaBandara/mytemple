import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/language_provider.dart';

class AlmsGuidelinesScreen extends StatelessWidget {
  const AlmsGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSi = context.watch<LanguageProvider>().isSinhala;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('alms_guidelines')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.saffronPrimary, AppColors.terracotta],
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
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('alms_guidelines'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('alms_guidelines_subtitle'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Morning Alms Guidelines Card
          _buildGuidelineCard(
            context: context,
            title: context.tr('morning_alms'),
            time: context.tr('morning_alms_time'),
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.morningAlms,
            bgColor: AppColors.morningAlmsBg,
            items: isSi
                ? [
                    'පෙ.ව. 6:00 ට පෙර විහාරස්ථානයට රැගෙන ආ යුතුය.',
                    'ඖෂධීය කැඳ (කොළ කැඳ / හාතාවාරිය / එළබටු කැඳ).',
                    'කිරිබත්, ආප්ප, ඉඳිආප්ප හෝ රතු කැකුළු බත්.',
                    'මෘදු ව්‍යංජන (පරිප්පු, සම්බෝල, කිරිහොදි, සීනි සම්බල්).',
                    'කෙසෙල්, පැණි දොඩම් හෝ නැවුම් පලතුරු.',
                    'උණුසුම් ගිලන්පස (තේ / කොළ තේ).'
                  ]
                : [
                    'Must arrive at the temple before 6:00 AM.',
                    'Herbal Porridge (Kola Kenda / Hathawariya).',
                    'Kiribath (Milk Rice), String Hoppers, or Steamed Rice.',
                    'Mild curries (Dhal curry, Lunu Miris, Kiri Hodi, Seeni Sambol).',
                    'Fresh bananas or sweet citrus fruits.',
                    'Hot beverage (Tea or herbal tea).'
                  ],
          ),
          const SizedBox(height: 16),

          // Lunch Alms Guidelines Card
          _buildGuidelineCard(
            context: context,
            title: context.tr('lunch_alms'),
            time: context.tr('lunch_alms_time'),
            icon: Icons.wb_sunny,
            iconColor: AppColors.lunchAlms,
            bgColor: AppColors.lunchAlmsBg,
            items: isSi
                ? [
                    'පෙ.ව. 11:00 ට පෙර විහාරස්ථානයට රැගෙන ආ යුතුය (11:15 ට පූජාව ඇරඹේ).',
                    'සුවඳැල්, රතු කැකුළු හෝ සම්බා බත්.',
                    'ව්‍යංජන 3 සිට 5 දක්වා (පරිප්පු, පොළොස්, පලා වර්ග, වම්බටු මෝජු ආදී).',
                    'අතුරුපස: මීකිරි සහ කිතුල් පැණි, වටලප්පන් හෝ පලතුරු සලාද.',
                    'පිරිසිදු උණුකර නිවාගත් පානීය පැන් සහ ගිලන්පස.',
                    'දැහැත් විට (බුලත්, පුවක්, කරාබුනැටි).'
                  ]
                : [
                    'Must arrive before 11:00 AM (Sanghika Dana starts at 11:15 AM).',
                    'Traditional Red or White Steamed Rice.',
                    '3 to 5 vegetarian or traditional curries (Polos, Dhal, Leafy greens, Brinjal moju).',
                    'Dessert: Curd & Kithul Treacle, Watalappan, or Fruit Platter.',
                    'Boiled and filtered drinking water & juices.',
                    'Traditional betel leaf offering (Dahat Vita).'
                  ],
          ),
          const SizedBox(height: 16),

          // Etiquette Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism, color: AppColors.saffronPrimary),
                      const SizedBox(width: 10),
                      Text(
                        isSi ? 'පූජා කිරීමේ චාරිත්‍ර හා ශුද්ධතාව' : 'Sacred Purity & Etiquette',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSi
                        ? '• දානය පිසින සියලු දෙනා පිරිසිදු සුදු ඇඳුමින් සැරසී සිටීම මැනවි.\n• දාන භාජන සුදු පිරිසිදු රෙදි කඩකින් ආවරණය කර රැගෙන එන්න.\n• සංඝරත්නය වඩින විට සාදුකාර දී පාද දෝවනය කර පිළිගන්න.\n• දානය පූජා කිරීමෙන් පසු මියගිය ඥාතීන්ට පිං අනුමෝදන් කරන්න.'
                        : '• Those preparing the alms should ideally wear clean white attire.\n• Cover all food vessels with clean white cloths during transport.\n• Offer water to wash feet and pay homage with Sadhu sadhu when the Sangha arrives.\n• Dedicate merit to departed relatives after the offering blessings.',
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard({
    required BuildContext context,
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<String> items,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.3)),
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
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: iconColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
