import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class RoleSwitchSheet extends StatelessWidget {
  const RoleSwitchSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RoleSwitchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSi = context.watch<LanguageProvider>().isSinhala;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            context.tr('switch_role_title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isSi
                ? 'පරිපාලන සහ දායක කාර්යයන් පරීක්ෂා කිරීම සඳහා පහත භූමිකාවන් අතර මාරු වන්න.'
                : 'Switch between user roles to test permissions, contributor views, and alms booking management.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            context: context,
            title: context.tr('role_super_admin'),
            description: context.tr('role_super_admin_desc'),
            userName: isSi ? 'මහානායක මණ්ඩල ප්‍රධාන පරිපාලක' : 'Super Admin (Mahanayaka Board)',
            icon: Icons.admin_panel_settings,
            role: UserRole.superAdmin,
            isSelected: auth.isSuperAdmin,
            accentColor: AppColors.templeMaroon,
            onTap: () {
              auth.switchRole(UserRole.superAdmin);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            context: context,
            title: context.tr('role_temple_admin'),
            description: context.tr('role_temple_admin_desc'),
            userName: isSi
                ? 'පූජ්‍ය බෙල්ලන්විල ධම්මරතන නායක හිමි'
                : 'Ven. Bellanwila Dhammarathana Thero',
            icon: Icons.temple_buddhist,
            role: UserRole.templeAdmin,
            isSelected: auth.isTempleAdmin,
            accentColor: AppColors.saffronPrimary,
            onTap: () {
              auth.switchRole(UserRole.templeAdmin);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            context: context,
            title: context.tr('role_contributor'),
            description: context.tr('role_contributor_desc'),
            userName: isSi ? 'සුනිල් පෙරේරා මහතා (දායකයා)' : 'Mr. Sunil Perera (Dayaka)',
            icon: Icons.volunteer_activism,
            role: UserRole.contributor,
            isSelected: auth.isContributor,
            accentColor: AppColors.statusAssigned,
            onTap: () {
              auth.switchRole(UserRole.contributor);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required String userName,
    required IconData icon,
    required UserRole role,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? accentColor : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: AppColors.statusAssigned, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
