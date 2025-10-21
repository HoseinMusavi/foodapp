// lib/core/error/exceptions.dart

class ServerException implements Exception {
  // --- CHANGE: Add a message property ---
  final String message;

  const ServerException({this.message = 'An unexpected error occurred.'});
}

class CacheException implements Exception {}
