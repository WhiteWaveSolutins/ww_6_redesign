import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  factory SubscriptionState([
    @Default(false) bool hasPremium,
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    @Default('') String errorMessage,
  ]) = _SubscriptionState;
}
