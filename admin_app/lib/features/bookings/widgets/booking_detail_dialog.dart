import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../providers/bookings_providers.dart';

class BookingDetailDialog extends ConsumerStatefulWidget {
  final Booking booking;

  const BookingDetailDialog({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailDialog> createState() =>
      _BookingDetailDialogState();
}

class _BookingDetailDialogState extends ConsumerState<BookingDetailDialog> {
  bool _isLoading = false;

  Future<void> _updateStatus(String nextStatus) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingsApiProvider)
          .updateBookingStatus(
            widget.booking.id,
            nextStatus,
            reason: 'Updated from admin dashboard',
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _issueRefund() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingsApiProvider)
          .requestRefund(widget.booking.id, 'Refunded via admin dashboard');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return AlertDialog(
      title: Text('Booking ${b.id.length > 8 ? b.id.substring(0, 8) : b.id}...'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: ${b.status.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text('User ID: ${b.userId}'),
              Text('Tour ID: ${b.tourId}'),
              Text('Total Price: ${b.currency} ${b.totalPrice.toInt()}'),
              if (b.bookingReferenceCode != null)
                Text('Reference: ${b.bookingReferenceCode}'),
              const Divider(),
              Text("Refunded: ${b.refunded ? 'Yes' : 'No'}"),
              if (b.refundReason != null)
                Text('Refund Reason: ${b.refundReason}'),
              if (b.paymentReferences != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Payment References:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(b.paymentReferences.toString()),
              ],
              if (b.adminNotes != null) Text('Admin Notes: ${b.adminNotes}'),
              if (b.tourSnapshot != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Trip Snapshot:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Title: ${b.tourSnapshot!['title'] ?? 'N/A'}"),
                Text("Destination: ${b.tourSnapshot!['destination'] ?? 'N/A'}"),
              ],
              if (b.participantCounts != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Participant Counts:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(b.participantCounts.toString()),
              ],
              if (b.bookingDate != null) Text('Booking Date: ${b.bookingDate}'),
              if (b.createdAt != null) Text('Created At: ${b.createdAt}'),
              const SizedBox(height: 24),
              const Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (b.status == 'pending')
                      ElevatedButton(
                        onPressed: () => _updateStatus('confirmed'),
                        child: const Text('Confirm Booking'),
                      ),
                    if (b.status == 'confirmed')
                      ElevatedButton(
                        onPressed: () => _updateStatus('completed'),
                        child: const Text('Mark Completed'),
                      ),
                    if (b.status == 'pending' || b.status == 'confirmed')
                      ElevatedButton(
                        onPressed: () => _updateStatus('cancelled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    if (!b.refunded)
                      ElevatedButton(
                        onPressed: _issueRefund,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Issue Refund'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
