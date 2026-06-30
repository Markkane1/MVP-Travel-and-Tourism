import '../errors/app_exception.dart';

/// A sealed class representing the result of an operation that can either
/// succeed with a value of type [T] or fail with an [AppException].
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppException exception) = Failure<T>;

  /// Executes [onSuccess] if success, or [onFailure] if failure.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(AppException exception) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else if (this is Failure<T>) {
      return onFailure((this as Failure<T>).exception);
    }
    throw StateError('Unknown Result type: $this');
  }

  /// Returns the value if success, or throws the exception if failure.
  T getOrThrow() {
    return when(
      onSuccess: (value) => value,
      onFailure: (exception) => throw exception,
    );
  }
}

/// A successful [Result] containing the [value].
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// A failed [Result] containing the [exception].
class Failure<T> extends Result<T> {
  final AppException exception;

  const Failure(this.exception);
}
