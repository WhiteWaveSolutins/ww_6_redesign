import 'package:redux/redux.dart';
import 'package:scan_doc/ui/state_manager/paywall/action.dart';
import 'package:scan_doc/ui/state_manager/paywall/state.dart';

final paywallListReducer = combineReducers<PaywallListState>([
  TypedReducer<PaywallListState, LoadPaywallListAction>(_loadPaywallList).call,
  TypedReducer<PaywallListState, ShowPaywallListAction>(_showPaywallList).call,
  TypedReducer<PaywallListState, ErrorPaywallListAction>(_errorPaywallList).call,
]);
// Save code
PaywallListState _loadPaywallList(
  PaywallListState state,
  LoadPaywallListAction action,
) =>
    state.copyWith(
      isLoading: true,
      isError: false,
    );

PaywallListState _showPaywallList(
  PaywallListState state,
  ShowPaywallListAction action,
) =>
    state.copyWith(
      isLoading: false,
      isError: false,
      paywalls: action.paywalls,
    );

PaywallListState _errorPaywallList(
  PaywallListState state,
  ErrorPaywallListAction action,
) =>
    state.copyWith(
      isLoading: false,
      isError: true,
      errorMessage: action.message,
    );
