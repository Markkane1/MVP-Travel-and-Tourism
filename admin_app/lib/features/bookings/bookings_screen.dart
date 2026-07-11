import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/bookings_providers.dart';
import 'widgets/booking_detail_dialog.dart';
import 'widgets/add_booking_dialog.dart';
import 'models/booking.dart';

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

    return Scaffold(
      body: SingleChildScrollView(
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddBookingDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Booking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            bookingsAsync.when(
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
                    final source = _BookingDataSource(
                      bookings: filteredBookings,
                      context: context,
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
                          header: const Text('Bookings Directory', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                          rowsPerPage: filteredBookings.length > 10 ? 10 : filteredBookings.length,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('User ID')),
                            DataColumn(label: Text('Tour ID')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Refunded')),
                            DataColumn(label: Text('Actions')),
                          ],
                        ),
                      ),
                    );
            },
          ), // bookingsAsync.when
          ],
        ),
      ),
    );
  }
}

class _BookingDataSource extends DataTableSource {
  final List<Booking> bookings;
  final BuildContext context;

  _BookingDataSource({required this.bookings, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= bookings.length) return null;
    final b = bookings[index];

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
                ? Colors.green.withValues(alpha: 0.1)
                : b.status == 'cancelled'
                    ? Colors.red.withValues(alpha: 0.1)
                    : b.status == 'completed'
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
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
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bookings.length;

  @override
  int get selectedRowCount => 0;
}
