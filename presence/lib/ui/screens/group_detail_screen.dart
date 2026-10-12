import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../models/group.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';
import 'youth_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refreshMembers();
  }

  void _refreshMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroupMembers(widget.group.id!);
    });
  }

  Future<void> _messageGroup() async {
    final provider = context.read<GroupProvider>();
    final adp = context.read<AdolescentProvider>();
    List<String> numbers = [];
    
    for (var youth in provider.currentGroupMembers) {
      final parents = await adp.getParents(youth.id!);
      for (var p in parents) {
        if (p.phone != null && p.phone!.isNotEmpty) {
          numbers.add(p.phone!);
        } else if (p.whatsapp != null && p.whatsapp!.isNotEmpty) {
          numbers.add(p.whatsapp!);
        }
      }
    }

    if (numbers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noParentNumbersFound)),
        );
      }
      return;
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.groupMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.parentNumbersFound(numbers.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: numbers.join(", ")));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.numbersCopied)),
                );
              },
              child: Text(l10n.copy),
            ),
          ],
        ),
      );
    }
  }

  void _showAddMembersDialog() async {
    final adp = context.read<AdolescentProvider>();
    final gp = context.read<GroupProvider>();
    final l10n = AppLocalizations.of(context)!;
    await adp.loadAdolescents();
    
    if (!mounted) return;

    final existingMemberIds = gp.currentGroupMembers.map((m) => m.id).toSet();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableYouth = adp.adolescents;
          
          return AlertDialog(
            title: Text(l10n.manageMembers, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableYouth.length,
                itemBuilder: (context, index) {
                  final youth = availableYouth[index];
                  final isMember = existingMemberIds.contains(youth.id);
                  
                  return CheckboxListTile(
                    title: Text(youth.fullName),
                    subtitle: Text(youth.phone ?? l10n.noPhoneNumber),
                    value: isMember,
                    onChanged: (bool? value) async {
                      if (value == true) {
                        await gp.addAdolescentToGroup(youth.id!, widget.group.id!);
                        setState(() => existingMemberIds.add(youth.id));
                      } else {
                        await gp.removeAdolescentFromGroup(youth.id!, widget.group.id!);
                        setState(() => existingMemberIds.remove(youth.id));
                      }
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
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_rounded),
            onPressed: _messageGroup,
            tooltip: l10n.contactParents,
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: kPagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.group.description != null && widget.group.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        widget.group.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.memberCount(provider.currentGroupMembers.length),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.groupMembers,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _showAddMembersDialog,
                    icon: Icon(Icons.group_add_rounded, color: theme.colorScheme.primary),
                    tooltip: l10n.manageMembers,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.currentGroupMembers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              Text(l10n.noYouthInGroup),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.currentGroupMembers.length,
                          itemBuilder: (context, index) {
                            final youth = provider.currentGroupMembers[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    youth.firstName[0],
                                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(youth.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(youth.phone ?? l10n.noPhoneNumber),
                                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => YouthDetailScreen(youth: youth),
                                  ),
                                ).then((_) => _refreshMembers()),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
