import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/services/already_exists_exception.dart';
import '../../models/adolescent.dart';
import '../../models/parent.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';

class AddAdolescentScreen extends StatefulWidget {
  final Adolescent? adolescent;
  const AddAdolescentScreen({super.key, this.adolescent});

  @override
  State<AddAdolescentScreen> createState() => _AddAdolescentScreenState();
}

class _AddAdolescentScreenState extends State<AddAdolescentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phonePrefixController = TextEditingController(text: '+228');
  final _addressController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _photoPath;
  
  final _p1FirstNameController = TextEditingController();
  final _p1LastNameController = TextEditingController();
  final _p1PhoneController = TextEditingController();
  final _p1PhonePrefixController = TextEditingController(text: '+228');
  final _p1WhatsappController = TextEditingController();
  final _p1WhatsappPrefixController = TextEditingController(text: '+228');
  String _p1Relation = 'father';

  final _p2FirstNameController = TextEditingController();
  final _p2LastNameController = TextEditingController();
  final _p2PhoneController = TextEditingController();
  final _p2PhonePrefixController = TextEditingController(text: '+228');
  final _p2WhatsappController = TextEditingController();
  final _p2WhatsappPrefixController = TextEditingController(text: '+228');
  String _p2Relation = 'mother';
  bool _showSecondParent = false;

  final Set<int> _selectedGroupIds = {};
  String _selectedGender = 'M';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.adolescent != null;
    if (_isEditing) {
      _firstNameController.text = widget.adolescent!.firstName;
      _lastNameController.text = widget.adolescent!.lastName;
      _parsePhone(widget.adolescent!.phone, _phonePrefixController, _phoneController);
      _addressController.text = widget.adolescent!.address ?? '';
      _selectedGender = widget.adolescent!.gender ?? 'M';
      _selectedBirthDate = widget.adolescent!.birthDate;
      _photoPath = widget.adolescent!.photoPath;
      _loadParents();
      _loadInitialGroups();
    }
  }

  void _parsePhone(String? fullPhone, TextEditingController prefixCtrl, TextEditingController phoneCtrl) {
    if (fullPhone == null || fullPhone.isEmpty) return;
    if (fullPhone.startsWith('+')) {
      // Simple heuristic: assume first 4 chars are prefix if it starts with + (e.g. +228)
      // or split by space if present
      if (fullPhone.contains(' ')) {
        final parts = fullPhone.split(' ');
        prefixCtrl.text = parts[0];
        phoneCtrl.text = parts.sublist(1).join('');
      } else {
        // Fallback for +XXX...
        prefixCtrl.text = fullPhone.substring(0, 4);
        phoneCtrl.text = fullPhone.substring(4);
      }
    } else {
      phoneCtrl.text = fullPhone;
    }
  }

  Future<void> _loadInitialGroups() async {
    final gp = context.read<GroupProvider>();
    final groupIds = await gp.getAdolescentGroupIds(widget.adolescent!.id!);
    if (mounted) {
      setState(() {
        _selectedGroupIds.addAll(groupIds);
      });
    }
  }

  Future<void> _loadParents() async {
    final parents = await context.read<AdolescentProvider>().getParents(widget.adolescent!.id!);
    if (parents.isNotEmpty) {
      final p1 = parents[0];
      if (mounted) {
        setState(() {
          _p1FirstNameController.text = p1.firstName ?? '';
          _p1LastNameController.text = p1.lastName ?? '';
          _parsePhone(p1.phone, _p1PhonePrefixController, _p1PhoneController);
          _parsePhone(p1.whatsapp, _p1WhatsappPrefixController, _p1WhatsappController);
          _p1Relation = p1.relation ?? 'father';
        });
      }
      if (parents.length > 1) {
        final p2 = parents[1];
        if (mounted) {
          setState(() {
            _showSecondParent = true;
            _p2FirstNameController.text = p2.firstName ?? '';
            _p2LastNameController.text = p2.lastName ?? '';
            _parsePhone(p2.phone, _p2PhonePrefixController, _p2PhoneController);
            _parsePhone(p2.whatsapp, _p2WhatsappPrefixController, _p2WhatsappController);
            _p2Relation = p2.relation ?? 'mother';
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: kPagePadding,
                child: Text(l10n.profilePhoto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source, maxWidth: 400);
      if (pickedFile != null && mounted) {
        setState(() => _photoPath = pickedFile.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupProvider = context.watch<GroupProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProfile : l10n.addYouth),
        centerTitle: true,
      ),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: kPagePadding,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                          child: _photoPath == null 
                            ? Icon(Icons.person_rounded, size: 70, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)) 
                            : null,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildSectionTitle(l10n.personalInfo),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _firstNameController,
                label: l10n.firstName,
                hint: l10n.firstNameHint,
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? l10n.firstNameRequired : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _lastNameController,
                label: l10n.lastName,
                hint: l10n.lastNameHint,
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? l10n.lastNameRequired : null,
              ),
              const SizedBox(height: 24),
              _buildDatePicker(context, l10n),
              const SizedBox(height: 24),
              _buildDropdown<String>(
                label: l10n.gender,
                value: _selectedGender,
                items: [
                  DropdownMenuItem(value: 'M', child: Text(l10n.male)),
                  DropdownMenuItem(value: 'F', child: Text(l10n.female)),
                ],
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 24),
              _buildGroupChips(groupProvider, l10n),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _phonePrefixController,
                      label: l10n.phonePrefix,
                      hint: "+228",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: l10n.phone,
                      hint: l10n.phoneHint,
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _addressController,
                label: l10n.address,
                hint: l10n.addressHint,
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 48),
              
              _buildSectionTitle(l10n.parentTutor),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _p1FirstNameController,
                label: l10n.parentFirstName,
                hint: l10n.parentFirstNameHint,
                icon: Icons.family_restroom_rounded,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _p1LastNameController,
                label: l10n.parentLastName,
                hint: l10n.parentLastNameHint,
                icon: Icons.family_restroom_rounded,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _p1PhonePrefixController,
                      label: l10n.phonePrefix,
                      hint: "+228",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _p1PhoneController,
                      label: l10n.parentPhone,
                      hint: l10n.parentPhoneHint,
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _p1WhatsappPrefixController,
                      label: l10n.phonePrefix,
                      hint: "+228",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _p1WhatsappController,
                      label: "WhatsApp",
                      hint: l10n.whatsappHint,
                      icon: Icons.message_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDropdown<String>(
                label: l10n.relation,
                value: _p1Relation,
                items: [
                  DropdownMenuItem(value: 'father', child: Text(l10n.father)),
                  DropdownMenuItem(value: 'mother', child: Text(l10n.mother)),
                  DropdownMenuItem(value: 'tutor', child: Text(l10n.tutor)),
                  DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                ],
                onChanged: (v) => setState(() => _p1Relation = v!),
              ),

              if (!_showSecondParent)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showSecondParent = true),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addSecondParent),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),

              if (_showSecondParent) ...[
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(l10n.secondParent),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                      onPressed: () => setState(() => _showSecondParent = false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _p2FirstNameController,
                  label: l10n.firstName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _p2LastNameController,
                  label: l10n.lastName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: _buildTextField(
                        controller: _p2PhonePrefixController,
                        label: l10n.phonePrefix,
                        hint: "+228",
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _p2PhoneController,
                        label: l10n.phone,
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: _buildTextField(
                        controller: _p2WhatsappPrefixController,
                        label: l10n.phonePrefix,
                        hint: "+228",
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _p2WhatsappController,
                        label: "WhatsApp",
                        hint: l10n.whatsappHint,
                        icon: Icons.message_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDropdown<String>(
                  label: l10n.relation,
                  value: _p2Relation,
                  items: [
                    DropdownMenuItem(value: 'father', child: Text(l10n.father)),
                    DropdownMenuItem(value: 'mother', child: Text(l10n.mother)),
                    DropdownMenuItem(value: 'tutor', child: Text(l10n.tutor)),
                    DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                  ],
                  onChanged: (v) => setState(() => _p2Relation = v!),
                ),
              ],

              const SizedBox(height: 64),
              SizedBox(
                height: 60,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChips(GroupProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.assignGroups, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.groups.map((group) {
            final isSelected = _selectedGroupIds.contains(group.id);
            return FilterChip(
              label: Text(group.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGroupIds.add(group.id!);
                  } else {
                    _selectedGroupIds.remove(group.id!);
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 24,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 22) : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    Widget? hint,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      hint: hint,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime(2010),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedBirthDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.cake_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthDate == null 
                    ? l10n.birthDate
                    : DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(_selectedBirthDate!),
                  style: TextStyle(
                    color: _selectedBirthDate == null 
                      ? Theme.of(context).colorScheme.onSurfaceVariant 
                      : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    String formatPhone(TextEditingController prefix, TextEditingController phone) {
      if (phone.text.isEmpty) return "";
      String p = phone.text.replaceAll(RegExp(r'[^0-9]'), '');
      String pre = prefix.text.trim();
      if (!pre.startsWith('+')) pre = '+$pre';
      return "$pre $p";
    }

    final adolescent = Adolescent(
      id: widget.adolescent?.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      gender: _selectedGender,
      phone: formatPhone(_phonePrefixController, _phoneController),
      address: _addressController.text,
      birthDate: _selectedBirthDate,
      photoPath: _photoPath,
    );

    List<Parent> parents = [];
    if (_p1FirstNameController.text.isNotEmpty || _p1PhoneController.text.isNotEmpty) {
      parents.add(Parent(
        firstName: _p1FirstNameController.text,
        lastName: _p1LastNameController.text,
        phone: formatPhone(_p1PhonePrefixController, _p1PhoneController),
        whatsapp: formatPhone(_p1WhatsappPrefixController, _p1WhatsappController),
        relation: _p1Relation,
        adolescentId: widget.adolescent?.id ?? 0,
      ));
    }
    
    if (_showSecondParent && (_p2FirstNameController.text.isNotEmpty || _p2PhoneController.text.isNotEmpty)) {
      parents.add(Parent(
        firstName: _p2FirstNameController.text,
        lastName: _p2LastNameController.text,
        phone: formatPhone(_p2PhonePrefixController, _p2PhoneController),
        whatsapp: formatPhone(_p2WhatsappPrefixController, _p2WhatsappController),
        relation: _p2Relation,
        adolescentId: widget.adolescent?.id ?? 0,
      ));
    }

    final ap = context.read<AdolescentProvider>();
    final gp = context.read<GroupProvider>();

    try {
      if (_isEditing) {
        await ap.updateAdolescent(adolescent, parents);
        await gp.syncAdolescentGroups(adolescent.id!, _selectedGroupIds);
      } else {
        final newId = await ap.insertRaw(adolescent, parents);
        for (var gId in _selectedGroupIds) {
          await gp.addAdolescentToGroup(newId, gId);
        }
      }
    } on AlreadyExistsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.youthNameExists(e.value))),
        );
      }
      return;
    }
    
    if (mounted) Navigator.pop(context);
  }
}
