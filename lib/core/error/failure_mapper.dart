import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failures.dart';

Failure mapToFailure(Object error, StackTrace stackTrace) {
  dev.log(
    'Data layer error',
    name: 'FailureMapper',
    error: error,
    stackTrace: stackTrace,
  );

  return switch (error) {
    SocketException() || TimeoutException() => const NetworkFailure(),
    AuthException() => const AuthFailure(),
    PostgrestException(code: '42501') => const PermissionFailure(),
    PostgrestException(code: 'PGRST116') => const NotFoundFailure(),
    PostgrestException() => const ServerFailure(),
    _ => const UnknownFailure(),
  };
}