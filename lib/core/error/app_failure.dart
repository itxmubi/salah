sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Unable to connect. Check your connection and try again.',
  ]);
}

final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'The service is temporarily unavailable.',
  ]);
}

final class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Saved data could not be read.']);
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Local data could not be accessed.']);
}

final class LocationFailure extends AppFailure {
  const LocationFailure([super.message = 'Location could not be determined.']);
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure([
    super.message = 'The required permission was not granted.',
  ]);
}

final class AudioFailure extends AppFailure {
  const AudioFailure([super.message = 'Audio could not be played.']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
