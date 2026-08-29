import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/temple_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/temple_provider.dart';

class AddEditTempleModal extends StatefulWidget {
  final TempleModel? temple;

  const AddEditTempleModal({super.key, this.temple});

  static Future<TempleModel?> show({
    required BuildContext context,
    TempleModel? temple,
  }) {
    return showModalBottomSheet<TempleModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTempleModal(temple: temple),
    );
  }

  @override
  State<AddEditTempleModal> createState() => _AddEditTempleModalState();
}

class _AddEditTempleModalState extends State<AddEditTempleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameSiController;
  late TextEditingController _addressController;
  late TextEditingController _districtController;
  late TextEditingController _phoneController;
  late TextEditingController _chiefMonkNameController;
  late TextEditingController _chiefMonkNameSiController;
  late TextEditingController _chiefMonkPhoneController;
  late int _monksCount;

  @override
  void initState() {
    super.initState();
    final t = widget.temple;
    _nameEnController = TextEditingController(text: t?.nameEn ?? '');
    _nameSiController = TextEditingController(text: t?.nameSi ?? '');
    _addressController = TextEditingController(text: t?.address ?? '');
    _districtController = TextEditingController(text: t?.district ?? 'Colombo');
    _phoneController = TextEditingController(text: t?.contactNumber ?? '');
    _chiefMonkNameController = TextEditingController(text: t?.chiefMonkName ?? '');
    _chiefMonkNameSiController = TextEditingController(text: t?.chiefMonkNameSi ?? '');
    _chiefMonkPhoneController = TextEditingController(text: t?.chiefMonkPhone ?? '');
    _monksCount = t?.residentMonksCount ?? 5;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameSiController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _chiefMonkNameController.dispose();
    _chiefMonkNameSiController.dispose();
    _chiefMonkPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.temple != null;

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
      child: Form(
        key: _formKey,
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
            Text(
              isEditing ? context.tr('edit_temple') : context.tr('add_temple'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameEnController,
                    decoration: InputDecoration(
                      labelText: context.tr('temple_name_en'),
                      prefixIcon: const Icon(Icons.temple_buddhist),
                      hintText: 'e.g. Bellanwila Rajamaha Viharaya',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter temple name in English'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameSiController,
                    decoration: InputDecoration(
                      labelText: context.tr('temple_name_si'),
                      prefixIcon: const Icon(Icons.translate),
                      hintText: 'උදා: බෙල්ලන්විල රජමහා විහාරය',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'කරුණාකර සිංහල නම ඇතුළත් කරන්න'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _districtController,
                          decoration: InputDecoration(
                            labelText: context.tr('district'),
                            prefixIcon: const Icon(Icons.map_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Enter district'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: context.tr('phone'),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: context.tr('address'),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resident monks stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('resident_monks'),
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
                  const Divider(),
                  const SizedBox(height: 8),

                  // Chief Monk details
                  Text(
                    context.tr('chief_monk'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _chiefMonkNameController,
                    decoration: const InputDecoration(
                      labelText: 'Chief Monk Name (English)',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'e.g. Ven. Medhananda Thero',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Enter Chief Monk name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _chiefMonkNameSiController,
                    decoration: const InputDecoration(
                      labelText: 'නායක හිමියන්ගේ නම (සිංහල)',
                      prefixIcon: Icon(Icons.translate),
                      hintText: 'උදා: පූජ්‍ය මේධානන්ද නායක හිමි',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _chiefMonkPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: context.tr('chief_monk_phone'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final templeProvider =
                      Provider.of<TempleProvider>(context, listen: false);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  if (isEditing) {
                    final updated = widget.temple!.copyWith(
                      nameEn: _nameEnController.text.trim(),
                      nameSi: _nameSiController.text.trim(),
                      address: _addressController.text.trim(),
                      district: _districtController.text.trim(),
                      contactNumber: _phoneController.text.trim(),
                      chiefMonkName: _chiefMonkNameController.text.trim(),
                      chiefMonkNameSi: _chiefMonkNameSiController.text.trim().isNotEmpty
                          ? _chiefMonkNameSiController.text.trim()
                          : _chiefMonkNameController.text.trim(),
                      chiefMonkPhone: _chiefMonkPhoneController.text.trim(),
                      residentMonksCount: _monksCount,
                    );
                    await templeProvider.updateTemple(updated);

                    // Update auth monk user
                    authProvider.setChiefMonkForTemple(
                      updated.id,
                      updated.chiefMonkName,
                      updated.chiefMonkNameSi,
                      updated.chiefMonkPhone,
                    );

                    if (context.mounted) Navigator.pop(context, updated);
                  } else {
                    final created = await templeProvider.addTemple(
                      nameEn: _nameEnController.text.trim(),
                      nameSi: _nameSiController.text.trim(),
                      address: _addressController.text.trim(),
                      district: _districtController.text.trim(),
                      contactNumber: _phoneController.text.trim(),
                      chiefMonkName: _chiefMonkNameController.text.trim(),
                      chiefMonkNameSi: _chiefMonkNameSiController.text.trim().isNotEmpty
                          ? _chiefMonkNameSiController.text.trim()
                          : _chiefMonkNameController.text.trim(),
                      chiefMonkPhone: _chiefMonkPhoneController.text.trim(),
                      residentMonksCount: _monksCount,
                    );

                    // Create chief monk user profile
                    authProvider.setChiefMonkForTemple(
                      created.id,
                      created.chiefMonkName,
                      created.chiefMonkNameSi,
                      created.chiefMonkPhone,
                    );

                    if (context.mounted) Navigator.pop(context, created);
                  }
                },
                child: Text(context.tr('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
