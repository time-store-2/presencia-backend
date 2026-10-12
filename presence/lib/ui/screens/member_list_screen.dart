import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedGroupId; // null means "All"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMembers();
      context.read<GroupProvider>().loadGroups();
      context.read<AttendanceProvider>().loadSessions();
    });
  }

  Future<void> _refreshData() async {
    await context.read<MemberProvider>().loadMembers();
    await context.read<GroupProvider>().loadGroups();
    await context.read<AttendanceProvider>().loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<MemberProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);

    // Filter logic
    var filteredMembers = provider.members.where((m) {
      final fullName = m.fullName.toLowerCase();
      final matchesSearch = fullName.contains(_searchQuery.toLowerCase());
      
      if (_selectedGroupId == null) return matchesSearch;
      
      // If a group is selected, we need to check if the member is in that group
      return matchesSearch && groupProvider.isMemberInGroup(m.id!, _selectedGroupId!);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.members),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: l10n.search,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  leading: Icon(Icons.search, color: theme.colorScheme.primary),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                ),
              ),
              _buildGroupFilter(groupProvider, theme, l10n),
            ],
          ),
        ),
      ),
      body: AppBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: filteredMembers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? l10n.noMemberFound : l10n.noResultsFor(_searchQuery),
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: kPagePadding,
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          
                          // Check for inactivity alerts
                          final alert = attendanceProvider.inactivityAlerts.firstWhere(
                            (a) => a['id'] == member.id,
                            orElse: () => {},
                          );
                          final missingCount = alert['missing_count'] as int? ?? 0;

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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: member.photoPath != null ? FileImage(File(member.photoPath!)) : null,
                                    child: member.photoPath == null 
                                      ? Text(member.firstName[0], 
                                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold))
                                      : null,
                                  ),
                                  if (missingCount >= 2)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: theme.colorScheme.surface, width: 2),
                                        ),
                                        child: Text(
                                          missingCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  if (missingCount >= 2)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l10n.absent,
                                        style: TextStyle(
                                          color: theme.colorScheme.onErrorContainer,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(member.phone ?? l10n.noPhone, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                              trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary.withOpacity(0.3)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemberDetailScreen(member: member),
                                ),
                              ).then((_) => context.read<MemberProvider>().loadMembers()),
                            ),
                          );
                        },
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'member_fab', // Unique tag to avoid Hero exception
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMemberScreen()),
        ).then((_) => context.read<MemberProvider>().loadMembers()),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildGroupFilter(GroupProvider provider, ThemeData theme, AppLocalizations l10n) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: provider.groups.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final group = isAll ? null : provider.groups[index - 1];
          final isSelected = isAll ? _selectedGroupId == null : _selectedGroupId == group?.id;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child:             ChoiceChip(
              label: Text(isAll ? l10n.all : group!.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedGroupId = isAll ? null : group?.id);
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
