import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/services_providers.dart';
import 'widgets/add_service_dialog.dart';
import 'widgets/edit_service_dialog.dart';
import 'models/service.dart';

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
      body: SingleChildScrollView(
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
            servicesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (services) {
                    final filteredServices = services.where((s) {
                      if (_filter == 'Active') return s.isActive;
                      if (_filter == 'Archived') return !s.isActive;
                      return true;
                    }).toList();

                    if (filteredServices.isEmpty) {
                      return const Center(child: Text('No services found.'));
                    }

                    final source = _ServiceDataSource(
                      services: filteredServices,
                      context: context,
                      ref: ref,
                    );
                    return SizedBox(
                      width: double.infinity,
                      child: Theme(
                        data: theme.copyWith(
                          cardTheme: const CardThemeData(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            clipBehavior: Clip.antiAlias,
                          ),
                        ),
                        child: PaginatedDataTable(
                          source: source,
                          header: const Text('Services Directory', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                          rowsPerPage: filteredServices.length > 10 ? 10 : filteredServices.length,
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Unit Type')),
                            DataColumn(label: Text('Sort Order')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                        ),
                      ),
                    );
                  },
                ), // servicesAsync.when
          ],
        ),
      ),
    );
  }
}

class _ServiceDataSource extends DataTableSource {
  final List<Service> services;
  final BuildContext context;
  final WidgetRef ref;

  _ServiceDataSource({required this.services, required this.context, required this.ref});

  @override
  DataRow? getRow(int index) {
    if (index >= services.length) return null;
    final service = services[index];

    return DataRow(
      cells: [
        DataCell(Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(service.category)),
        DataCell(Text('${service.currency} ${service.basePrice.toStringAsFixed(2)}')),
        DataCell(Text(service.unitType.replaceAll('_', ' '))),
        DataCell(Text(service.sortOrder.toString())),
        DataCell(
          Chip(
            label: Text(service.isActive ? 'Active' : 'Archived'),
            backgroundColor: service.isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: service.isActive ? Colors.green : Colors.grey,
            ),
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
                    await ref
                        .read(servicesApiProvider)
                        .archiveService(service.id, 'admin_user');
                  },
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => services.length;

  @override
  int get selectedRowCount => 0;
}
