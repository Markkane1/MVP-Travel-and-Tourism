import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/result.dart';

part 'trips_repository.g.dart';

class TripsRepository {
  final ApiClient _api;

  TripsRepository(this._api);

  /// Cancels the booking through the backend API.
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await _api.postJson('/bookings/$bookingId/cancel', {});
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Cancellation failed: ${e.toString()}'),
      );
    }
  }
}

@riverpod
TripsRepository tripsRepository(Ref ref) {
  return TripsRepository(ref.watch(apiClientProvider));
}
