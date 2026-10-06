sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) success,
    required R Function(Object error) failure,
  });
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>({
    required R Function(T value) success,
    required R Function(Object error) failure,
  }) => success(value);
}

final class Error<T> extends Result<T> {
  const Error(this.error);

  final Object error;

  @override
  R fold<R>({
    required R Function(T value) success,
    required R Function(Object error) failure,
  }) => failure(error);
}
