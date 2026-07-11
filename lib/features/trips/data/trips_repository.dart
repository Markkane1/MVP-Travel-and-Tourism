import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';

part 'trips_repository.g.dart';

class TripsRepository {
  final FirebaseFunctions _functions;

  TripsRepository(this._functions);

  /// Triggers the cloud function to cancel the booking.
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await _functions.httpsCallable('cancelBooking').call({
        'bookingId': bookingId,
      });
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
  return TripsRepository(FirebaseFunctions.instance);
}
