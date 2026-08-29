import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/contributor_model.dart';
import '../../../providers/contributor_provider.dart';

class AddEditContributorModal extends StatefulWidget {
  final String templeId;
  final ContributorModel? contributor;

  const AddEditContributorModal({
    super.key,
    required this.templeId,
    this.contributor,
  });

  static Future<ContributorModel?> show({
    required BuildContext context,
    required String templeId,
    ContributorModel? contributor,
  }) {
    return showModalBottomSheet<ContributorModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditContributorModal(
        templeId: templeId,
        contributor: contributor,
      ),
    );
  }

  @override
  State<AddEditContributorModal> createState() =>
      _AddEditContributorModalState();
}

class _AddEditContributorModalState extends State<AddEditContributorModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameSiController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _familyController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final c = widget.contributor;
    _nameController = TextEditingController(text: c?.fullName ?? '');
    _nameSiController = TextEditingController(text: c?.fullNameSi ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _familyController = TextEditingController(text: c?.familyName ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameSiController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _familyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contributor != null;

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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              isEditing
                  ? context.tr('edit_contributor')
                  : context.tr('add_contributor'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.tr('contributor_name'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter full name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameSiController,
                    decoration: InputDecoration(
                      labelText: context.tr('contributor_name_si'),
                      prefixIcon: const Icon(Icons.translate),
                      hintText: 'උදා: සුනිල් පෙරේරා මහතා',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: context.tr('phone'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      hintText: '+94 77 123 4567',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter phone number'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: context.tr('address'),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _familyController,
                    decoration: InputDecoration(
                      labelText: context.tr('family_name'),
                      prefixIcon: const Icon(Icons.family_restroom_outlined),
                      hintText: 'e.g. Perera Family / පෙරේරා පවුල',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.tr('notes'),
                      prefixIcon: const Icon(Icons.notes_outlined),
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

                  final provider =
                      Provider.of<ContributorProvider>(context, listen: false);

                  if (isEditing) {
                    final updated = widget.contributor!.copyWith(
                      fullName: _nameController.text.trim(),
                      fullNameSi: _nameSiController.text.trim().isNotEmpty
                          ? _nameSiController.text.trim()
                          : _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: _addressController.text.trim(),
                      familyName: _familyController.text.trim().isEmpty
                          ? null
                          : _familyController.text.trim(),
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    );
                    await provider.updateContributor(updated);
                    if (context.mounted) Navigator.pop(context, updated);
                  } else {
                    final created = await provider.addContributor(
                      templeId: widget.templeId,
                      fullName: _nameController.text.trim(),
                      fullNameSi: _nameSiController.text.trim().isNotEmpty
                          ? _nameSiController.text.trim()
                          : _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: _addressController.text.trim(),
                      familyName: _familyController.text.trim().isEmpty
                          ? null
                          : _familyController.text.trim(),
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
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
