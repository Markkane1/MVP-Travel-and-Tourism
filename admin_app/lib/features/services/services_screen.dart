import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/services_providers.dart';
import 'widgets/add_service_dialog.dart';
import 'widgets/edit_service_dialog.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _filter = 'All'; // 'All', 'Active', 'Archived'

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services Management',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _filter,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _filter = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddServiceDialog(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Service'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
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
                child: servicesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (services) {
                    final filteredServices = services.where((s) {
                      if (_filter == 'Active') return s.isActive;
                      if (_filter == 'Archived') return !s.isActive;
                      return true; // All
                    }).toList();

                    if (filteredServices.isEmpty) {
                      return const Center(child: Text('No services found.'));
                    }
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Unit Type')),
                            DataColumn(label: Text('Sort Order')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredServices.map((service) {
                            return DataRow(
                              cells: [
                                DataCell(Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(service.category)),
                                DataCell(Text('\${service.currency} \${service.basePrice.toStringAsFixed(2)}')),
                                DataCell(Text(service.unitType.replaceAll('_', ' '))),
                                DataCell(Text(service.sortOrder.toString())),
                                DataCell(
                                  Chip(
                                    label: Text(service.isActive ? 'Active' : 'Archived'),
                                    backgroundColor: service.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    labelStyle: TextStyle(color: service.isActive ? Colors.green : Colors.grey),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => EditServiceDialog(service: service),
                                          );
                                        },
                                      ),
                                      if (service.isActive)
                                        IconButton(
                                          icon: const Icon(Icons.archive, size: 20),
                                          onPressed: () async {
                                            // Archive service
                                            await ref.read(servicesApiProvider).archiveService(service.id, 'admin_user');
                                          },
                                          color: Colors.orange,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
