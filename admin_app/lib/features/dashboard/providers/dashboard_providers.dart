import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';

final totalBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/bookings');
});

final totalToursProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/tours', where: (item) => item['status'] != 'ARCHIVED');
});

final totalConciergeThreadsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/concierge/threads');
});

final totalReviewsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/reviews/recent');
});

// Phase 9 additional reporting metrics:

final pendingBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/bookings', where: (item) => item['status'] == 'PENDING');
});

final confirmedBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(
    ref,
    '/admin/bookings',
    where: (item) => item['status'] == 'CONFIRMED',
  );
});

final activeServicesProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/services', where: (item) => item['status'] == 'ACTIVE');
});

final recentRefundsProvider = StreamProvider.autoDispose<int>((ref) {
  return _count(ref, '/admin/audit?action=ISSUE_REFUND');
});

Stream<int> _count(
  Ref ref,
  String path, {
  bool Function(Map<String, dynamic> item)? where,
}) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(api.getJson(path).then((data) {
    final items = (data as List).map((item) => Map<String, dynamic>.from(item as Map));
    return where == null ? items.length : items.where(where).length;
  }));
}
