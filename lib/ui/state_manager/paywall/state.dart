import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scan_doc/data/models/paywalls/paywall.dart';

part 'state.freezed.dart';

@freezed
class PaywallListState with _$PaywallListState {
  factory PaywallListState([
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    @Default('') String errorMessage,
    @Default([]) List<Paywall> paywalls,
  ]) = _PaywallListState;
}
