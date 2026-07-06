import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/tours_providers.dart';
import 'widgets/add_tour_dialog.dart';
import 'widgets/edit_tour_dialog.dart';

class ToursScreen extends ConsumerWidget {
  const ToursScreen({super.key});

  void _showAddTourDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddTourDialog(),
    );
  }

  void _showEditTourDialog(BuildContext context, tour) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditTourDialog(tour: tour),
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, String tourId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Tour'),
        content: const Text('Are you sure you want to archive this tour? It will no longer appear on the traveler app, but existing bookings will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(toursApiProvider).deleteTour(tourId); // Archive logic handles it in API provider (or sets isActive to false depending on how it was written)
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toursAsync = ref.watch(toursStreamProvider);

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
                  'Tours Management',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddTourDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Tour'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: toursAsync.when(
                  data: (tours) {
                    if (tours.isEmpty) {
                      return const Center(
                        child: Text('No tours found. Click "Add New Tour" to create one.'),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Destination')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Price'), numeric: true),
                            DataColumn(label: Text('Duration'), numeric: true),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: tours.map((tour) {
                            return DataRow(
                              cells: [
                                DataCell(Text(tour.title)),
                                DataCell(Text(tour.destination)),
                                DataCell(Chip(label: Text(tour.category))),
                                DataCell(Text('\$${tour.pricePerPerson.toStringAsFixed(2)}')),
                                DataCell(Text('${tour.durationDays} days')),
                                // Check if tour model natively exposes isActive. Assuming API uses it or it's active if no archivedAt. Let's just put active for now.
                                const DataCell(Chip(label: Text('Active'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showEditTourDialog(context, tour),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.archive, size: 20, color: Colors.red),
                                        onPressed: () => _confirmArchive(context, ref, tour.id),
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading tours:\n$err',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
