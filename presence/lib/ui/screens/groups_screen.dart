import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../core/providers/group_provider.dart';
import '../../core/services/already_exists_exception.dart';
import '../../models/group.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<GroupProvider>();
    final design = Theme.of(context).extension<AppDesignSystem>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groups),
      ),
      body: AppBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.groups.isEmpty
                ? Center(child: Text(l10n.noGroups, style: Theme.of(context).textTheme.bodyLarge))
                : ListView.builder(
                    padding: kPagePadding,
                    itemCount: provider.groups.length,
                    itemBuilder: (context, index) {
                      final group = provider.groups[index];
                      return GlassCard(
                        margin: EdgeInsets.only(bottom: design.spacingUnit * 4),
                        padding: EdgeInsets.zero,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupDetailScreen(group: group),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: group.color != null ? Color(group.color!) : Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.group_rounded, color: Colors.white),
                          ),
                          title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(group.description ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                            onPressed: () => _confirmDelete(context, group),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'groups_fab', // Added unique heroTag
        onPressed: () => _showAddGroupDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newGroup),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newGroup, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.groupName, hintText: l10n.groupNameHint),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: l10n.description),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final group = Group(
                  name: nameController.text,
                  description: descController.text,
                  createdAt: DateTime.now(),
                );
                try {
                  await context.read<GroupProvider>().addGroup(group);
                  if (context.mounted) Navigator.pop(context);
                } on AlreadyExistsException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.groupNameExists(e.value))),
                    );
                  }
                }
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Group group) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGroupQuestion),
        content: Text(l10n.confirmDeleteGroup(group.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<GroupProvider>().deleteGroup(group.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
