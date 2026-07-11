import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/bookings_providers.dart';
import 'widgets/booking_detail_dialog.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _statusFilter = 'All'; // All, Pending, Confirmed, Completed, Cancelled
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Bookings Operations',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search User or Tour ID',
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
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _statusFilter = val;
                      });
                    }
                  },
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
                child: bookingsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (bookings) {
                    final filteredBookings = bookings.where((b) {
                      bool matchesStatus = true;
                      if (_statusFilter != 'All') {
                        matchesStatus = b.status.toLowerCase() == _statusFilter.toLowerCase();
                      }
                      bool matchesSearch = true;
                      if (_searchQuery.isNotEmpty) {
                        matchesSearch = b.userId.toLowerCase().contains(_searchQuery) ||
                                        b.tourId.toLowerCase().contains(_searchQuery) ||
                                        (b.bookingReferenceCode?.toLowerCase().contains(_searchQuery) ?? false);
                      }
                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredBookings.isEmpty) {
                      return const Center(child: Text('No bookings found.'));
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
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('User ID')),
                            DataColumn(label: Text('Tour ID')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Refunded')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredBookings.map((b) {
                            return DataRow(
                              onSelectChanged: (_) {
                                showDialog(
                                  context: context,
                                  builder: (context) => BookingDetailDialog(booking: b),
                                );
                              },
                              cells: [
                                DataCell(Text(b.id.substring(0, 8))),
                                DataCell(Text(b.userId.substring(0, 8))),
                                DataCell(Text(b.tourId.substring(0, 8))),
                                DataCell(Text('${b.currency} ${b.totalPrice.toInt()}')),
                                DataCell(
                                  Chip(
                                    label: Text(b.status.toUpperCase()),
                                    backgroundColor: b.status == 'confirmed'
                                        ? Colors.green.withOpacity(0.1)
                                        : b.status == 'cancelled'
                                            ? Colors.red.withOpacity(0.1)
                                            : b.status == 'completed'
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.orange.withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: b.status == 'confirmed'
                                          ? Colors.green
                                          : b.status == 'cancelled'
                                              ? Colors.red
                                              : b.status == 'completed'
                                                  ? Colors.blue
                                                  : Colors.orange,
                                    ),
                                  ),
                                ),
                                DataCell(Text(b.refunded ? 'Yes' : 'No')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Manage Booking',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => BookingDetailDialog(booking: b),
                                      );
                                    },
                                  ),
                                ),
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
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
