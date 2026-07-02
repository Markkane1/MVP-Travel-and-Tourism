import '../errors/app_exception.dart';

extension SafeStream<T> on Stream<T> {
  Stream<T> mapAppException(String message) {
    return handleError((error, stackTrace) {
      throw AppException.unknown('$message: ${error.toString()}');
    });
  }
}
