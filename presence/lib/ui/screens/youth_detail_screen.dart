import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presencia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../models/adolescent.dart';
import '../../models/parent.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/glass_card.dart';
import 'add_adolescent_screen.dart';

class YouthDetailScreen extends StatefulWidget {
  final Adolescent youth;
  const YouthDetailScreen({super.key, required this.youth});

  @override
  State<YouthDetailScreen> createState() => _YouthDetailScreenState();
}

class _YouthDetailScreenState extends State<YouthDetailScreen> {
  late Adolescent _currentYouth;
  List<Parent> _parents = [];
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _history = [];
  List<String> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentYouth = widget.youth;
    _loadData();
  }

  Future<void> _loadData() async {
    final ap = context.read<AdolescentProvider>();
    final atp = context.read<AttendanceProvider>();

    final parents = await ap.getParents(_currentYouth.id!);
    final stats = await atp.getAdolescentStats(_currentYouth.id!);
    final history = await atp.getHistoryForAdolescent(_currentYouth.id!);
    final badges = await atp.getAdolescentBadges(_currentYouth.id!);
    
    if (mounted) {
      setState(() {
        _parents = parents;
        _stats = stats;
        _history = history;
        _badges = badges;
        _isLoading = false;
      });
    }
  }

  /// Admin : ajoute/retire le membre de groupes (cases à cocher).
  Future<void> _showEditGroupsDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final gp = context.read<GroupProvider>();
    await gp.loadGroups();
    final current = Set<int>.from(
      await gp.getAdolescentGroupIds(_currentYouth.id!),
    );
    if (!mounted) return;
    final selected = Set<int>.from(current);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            l10n.editMemberGroups,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: gp.groups.isEmpty
                ? Text(l10n.emptyList)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: gp.groups.length,
                    itemBuilder: (context, index) {
                      final group = gp.groups[index];
                      return CheckboxListTile(
                        title: Text(group.name),
                        value: selected.contains(group.id),
                        onChanged: (bool? value) async {
                          if (value == true) {
                            selected.add(group.id!);
                          } else {
                            selected.remove(group.id);
                          }
                          await gp.syncAdolescentGroups(
                            _currentYouth.id!,
                            selected,
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile),
        content: Text(l10n.confirmDeleteYouth(_currentYouth.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<AdolescentProvider>().deleteAdolescent(_currentYouth.id!);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentYouth.fullName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.hub_outlined),
              tooltip: l10n.editMemberGroups,
              onPressed: _showEditGroupsDialog,
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddAdolescentScreen(adolescent: _currentYouth),
              ),
            ).then((_) {
              context.read<AdolescentProvider>().loadAdolescents().then((_) {
                final updated = context.read<AdolescentProvider>().adolescents.firstWhere((a) => a.id == _currentYouth.id);
                setState(() {
                  _currentYouth = updated;
                });
                _loadData();
              });
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Container(
        decoration: _buildBackgroundDecoration(context),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, design),
                if (_badges.isNotEmpty) ...[
                  SizedBox(height: design.spacingUnit * 2),
                  _buildBadges(context, design),
                ],
                SizedBox(height: design.spacingUnit * 3),
                _buildStats(context, design, statusColors, l10n),
                SizedBox(height: design.spacingUnit * 3),
                Text(l10n.parentTutor, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: design.spacingUnit),
                if (_parents.isEmpty)
                  GlassCard(child: Center(child: Text(l10n.noParentInfo)))
                else
                  ..._parents.map((p) => _ParentCard(parent: p)),
                SizedBox(height: design.spacingUnit * 3),
                Text(l10n.history, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: design.spacingUnit),
                _buildHistory(context, design, statusColors, l10n),
              ],
            ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark && theme.colorScheme.primary == const Color(0xFFC3DFD3)) {
      return const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.centerRight,
          radius: 1.5,
          colors: [Color(0xFF1D2E28), Color(0xFF111413)],
        ),
      );
    }
    return BoxDecoration(color: theme.colorScheme.surface);
  }

  Widget _buildHeader(BuildContext context, AppDesignSystem design) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: _currentYouth.photoPath != null ? FileImage(File(_currentYouth.photoPath!)) : null,
          child: _currentYouth.photoPath == null 
            ? Text(
                _currentYouth.firstName[0], 
                style: TextStyle(fontSize: 48, color: Theme.of(context).colorScheme.onPrimaryContainer),
              )
            : null,
        ),
        SizedBox(height: design.spacingUnit * 2),
        Text(
          _currentYouth.fullName, 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (_currentYouth.birthDate != null)
           Text(
             l10n.bornOn(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(_currentYouth.birthDate!)),
             style: Theme.of(context).textTheme.bodyMedium,
           ),
        if (_currentYouth.phone != null && _currentYouth.phone!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentYouth.phone!, 
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.phone_forwarded_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                onPressed: () => _launchPhone(_currentYouth.phone),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.message_rounded, size: 20, color: Color(0xFF25D366)),
                onPressed: () => _launchWhatsapp(_currentYouth.phone),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _launchPhone(String? phoneNumber) async {
    final phone = phoneNumber?.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  Future<void> _launchWhatsapp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    
    // WhatsApp nécessite format international pur: chiffres uniquement
    final phone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    final url = Uri.parse("https://wa.me/$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse("whatsapp://send?phone=$phone"), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  Widget _buildBadges(BuildContext context, AppDesignSystem design) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: _badges.map((badge) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(badge, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildStats(BuildContext context, AppDesignSystem design, StatusColors statusColors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _StatItem(label: l10n.present, value: _stats['present'] ?? 0, color: statusColors.presentText)),
        SizedBox(width: design.spacingUnit),
        Expanded(child: _StatItem(label: l10n.late, value: _stats['late'] ?? 0, color: statusColors.lateText)),
        SizedBox(width: design.spacingUnit),
        Expanded(child: _StatItem(label: l10n.absent, value: _stats['absent'] ?? 0, color: statusColors.absentText)),
        SizedBox(width: design.spacingUnit),
        Expanded(child: _StatItem(label: l10n.excused, value: _stats['excused'] ?? 0, color: statusColors.excusedText)),
      ],
    );
  }

  Widget _buildHistory(BuildContext context, AppDesignSystem design, StatusColors statusColors, AppLocalizations l10n) {
    if (_history.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(l10n.noHistory)),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(_history.length, (index) {
          final item = _history[index];
          final date = DateTime.parse(item['session_date'] as String);
          final status = item['status'] as String;
          final comment = item['comment'] as String?;
          
          Color textColor;
          String label;
          switch (status) {
            case 'present':
              textColor = statusColors.presentText;
              label = l10n.present;
              break;
            case 'absent':
              textColor = statusColors.absentText;
              label = l10n.absent;
              break;
            case 'late':
              textColor = statusColors.lateText;
              label = l10n.late;
              break;
            case 'excused':
              textColor = statusColors.excusedText;
              label = l10n.excused;
              break;
            default:
              textColor = Theme.of(context).colorScheme.onSurface;
              label = status;
          }

          return Column(
            children: [
              ListTile(
                title: Text(item['session_title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date)),
                    if (comment != null && comment.isNotEmpty)
                      Text(
                        comment,
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(design.radiusSm),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              if (index < _history.length - 1) const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.1),
            ],
          );
        }),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  final Parent parent;
  const _ParentCard({required this.parent});

  Future<void> _call() async {
    final phone = parent.phone?.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback pour certains appareils si canLaunchUrl échoue
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  Future<void> _whatsapp() async {
    String phone = parent.whatsapp ?? parent.phone ?? "";
    if (phone.isEmpty) return;
    
    // WhatsApp nécessite format international pur: chiffres uniquement
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    final url = Uri.parse("https://wa.me/$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Alternative si le schéma wa.me n'est pas reconnu direct
        await launchUrl(Uri.parse("whatsapp://send?phone=$phone"), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    String relationLabel;
    switch (parent.relation) {
      case 'father': relationLabel = l10n.father; break;
      case 'mother': relationLabel = l10n.mother; break;
      case 'tutor': relationLabel = l10n.tutor; break;
      case 'other': relationLabel = l10n.other; break;
      default: relationLabel = parent.relation ?? "";
    }

    return GlassCard(
      margin: EdgeInsets.only(bottom: design.spacingUnit),
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text("${parent.fullName} ($relationLabel)", style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(parent.phone ?? parent.whatsapp ?? ""),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (parent.phone != null && parent.phone!.isNotEmpty) 
              IconButton(
                icon: Icon(Icons.phone_forwarded_rounded, size: 22, color: theme.colorScheme.primary), 
                onPressed: _call,
              ),
            if ((parent.whatsapp != null && parent.whatsapp!.isNotEmpty) || (parent.phone != null && parent.phone!.isNotEmpty)) 
              IconButton(
                icon: const Icon(Icons.message_rounded, size: 22, color: Color(0xFF25D366)), 
                onPressed: _whatsapp,
              ),
          ],
        ),
      ),
    );
  }
}
