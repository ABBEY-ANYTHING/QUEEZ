/// Custom exceptions for the Queez app
/// Provides specific exception types for better error handling and debugging
library;

/// Base exception class for all Queez app exceptions
abstract class QueezException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const QueezException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => message;
}

/// Thrown when a user is not authenticated but tries to access protected resources
class AuthenticationException extends QueezException {
  const AuthenticationException([
    super.message = 'User not authenticated',
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(originalError: originalError, stackTrace: stackTrace);
}

/// Thrown when a user doesn't have permission to perform an action
class PermissionException extends QueezException {
  const PermissionException([
    super.message = 'You do not have permission to perform this action',
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(originalError: originalError, stackTrace: stackTrace);
}

/// Thrown when a requested resource is not found
class NotFoundException extends QueezException {
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    String message = 'Resource not found',
    this.resourceType,
    this.resourceId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() {
    if (resourceType != null && resourceId != null) {
      return '$resourceType with ID $resourceId not found';
    }
    return message;
  }
}

/// Thrown when a route is not found in the route map
class RouteNotFoundException extends QueezException {
  final String routeName;

  const RouteNotFoundException(
    this.routeName, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         'Route "$routeName" not found in routeMap',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Thrown when there's a network-related error
class NetworkException extends QueezException {
  final int? statusCode;

  const NetworkException({
    String message = 'Network error. Please check your connection.',
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() {
    if (statusCode != null) {
      return '$message (Status: $statusCode)';
    }
    return message;
  }
}

/// Thrown when an API request fails
class ApiException extends QueezException {
  final int? statusCode;
  final String? endpoint;

  const ApiException({
    required String message,
    this.statusCode,
    this.endpoint,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() {
    final parts = <String>[message];
    if (statusCode != null) parts.add('Status: $statusCode');
    if (endpoint != null) parts.add('Endpoint: $endpoint');
    return parts.join(' | ');
  }
}

/// Thrown when a request times out
class TimeoutException extends QueezException {
  final Duration? duration;

  const TimeoutException({
    String message = 'Request timed out',
    this.duration,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() {
    if (duration != null) {
      return '$message after ${duration!.inSeconds}s';
    }
    return message;
  }
}

/// Thrown when WebSocket connection fails
class WebSocketException extends QueezException {
  final String? url;

  const WebSocketException({
    String message = 'WebSocket connection failed',
    this.url,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

/// Thrown when validation fails
class ValidationException extends QueezException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    String message = 'Validation failed',
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

/// Thrown when an invalid item type is provided
class InvalidItemTypeException extends QueezException {
  final String itemType;
  final List<String>? validTypes;

  const InvalidItemTypeException(
    this.itemType, {
    this.validTypes,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         'Invalid item type: $itemType',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String toString() {
    if (validTypes != null && validTypes!.isNotEmpty) {
      return 'Invalid item type: $itemType. Valid types: ${validTypes!.join(', ')}';
    }
    return message;
  }
}

/// Thrown when a session is expired or invalid
class SessionException extends QueezException {
  final String? sessionCode;

  const SessionException({
    String message = 'Session expired or invalid',
    this.sessionCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

/// Thrown when a favorite operation fails
class FavoriteException extends QueezException {
  final String itemId;
  final String operation; // 'add', 'remove', 'toggle'

  const FavoriteException({
    required this.itemId,
    required this.operation,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message ?? 'Failed to $operation favorite for item $itemId',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Thrown when a delete operation fails
class DeleteException extends QueezException {
  final String? itemId;
  final String? itemType;

  const DeleteException({
    String message = 'Failed to delete item',
    this.itemId,
    this.itemType,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() {
    if (itemType != null && itemId != null) {
      return 'Failed to delete $itemType with ID $itemId';
    }
    return message;
  }
}

/// Thrown when a storage operation fails
class StorageException extends QueezException {
  const StorageException({
    String message = 'Storage operation failed',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}
