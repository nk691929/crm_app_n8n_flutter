import 'dart:async';

import 'failure_mapper.dart';
import 'result.dart';

Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } catch (error, stackTrace) {
    return Err(mapToFailure(error, stackTrace));
  }
}

Stream<T> guardStream<T>(Stream<T> source) {
  return source.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) =>
          sink.addError(mapToFailure(error, stackTrace), stackTrace),
    ),
  );
}