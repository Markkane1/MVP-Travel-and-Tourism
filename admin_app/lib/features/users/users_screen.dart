import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/users_providers.dart';
import 'widgets/user_detail_dialog.dart';
import 'widgets/add_user_dialog.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Users Management',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by Email or Name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddUserDialog(),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: usersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (users) {
                    final filteredUsers = users.where((u) {
                      if (_searchQuery.isEmpty) return true;
                      return u.email.toLowerCase().contains(_searchQuery) ||
                             (u.displayName?.toLowerCase().contains(_searchQuery) ?? false) ||
                             u.id.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(label: Text('User ID')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Tier')),
                            DataColumn(label: Text('Loyalty Pts')),
                            DataColumn(label: Text('Concierge ID')),
                          ],
                          rows: filteredUsers.map((u) {
                            return DataRow(
                              onSelectChanged: (_) {
                                showDialog(
                                  context: context,
                                  builder: (context) => UserDetailDialog(user: u),
                                );
                              },
                              cells: [
                                DataCell(Text(u.id.substring(0, 8))),
                                DataCell(Text(u.email)),
                                DataCell(Text(u.displayName ?? '-')),
                                DataCell(
                                  Chip(
                                    label: Text(u.tier.toUpperCase()),
                                    backgroundColor: u.tier == 'platinum'
                                        ? Colors.purple.withValues(alpha: 0.1)
                                        : u.tier == 'gold'
                                            ? Colors.orange.withValues(alpha: 0.1)
                                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                                  ),
                                ),
                                DataCell(Text(u.loyaltyPoints.toString())),
                                DataCell(Text(u.conciergeId ?? 'Unassigned')),
                              ],
                            );
                          }).toList(),
                        ), // DataTable
                      ), // ConstrainedBox
                    ), // SingleChildScrollView
                  ); // return SingleChildScrollView
                },
              ); // return LayoutBuilder
            },
          ), // usersAsync.when data
        ), // Card
      ), // Expanded
          ],
        ),
      ),
    );
  }
}
