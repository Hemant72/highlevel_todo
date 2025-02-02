import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.serverError() = ServerError;
  const factory Failure.cacheError() = CacheError;
  const factory Failure.invalidInput() = InvalidInput;
  const factory Failure.database() = DatabaseFailure;
}
