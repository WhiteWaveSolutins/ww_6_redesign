import 'package:redux/redux.dart';
import 'package:scan_doc/ui/state_manager/subscription/action.dart';
import 'package:scan_doc/ui/state_manager/subscription/state.dart';

final subscriptionReducer = combineReducers<SubscriptionState>([
  TypedReducer<SubscriptionState, LoadSubscriptionAction>(_loadSubscription).call,
  TypedReducer<SubscriptionState, ShowSubscriptionAction>(_showSubscription).call,
  TypedReducer<SubscriptionState, ErrorSubscriptionAction>(_errorSubscription).call,
  TypedReducer<SubscriptionState, RestoreSubscriptionAction>(_restoreSubscription).call,
  TypedReducer<SubscriptionState, PurchaseSubscriptionAction>(_purchaseSubscription).call,
]);

SubscriptionState _purchaseSubscription(
  SubscriptionState state,
  PurchaseSubscriptionAction action,
) =>
    state.copyWith(
      isLoading: true,
      isError: false,
    );

SubscriptionState _restoreSubscription(
  SubscriptionState state,
  RestoreSubscriptionAction action,
) =>
    state.copyWith(
      isLoading: true,
      isError: false,
    );

SubscriptionState _loadSubscription(
  SubscriptionState state,
  LoadSubscriptionAction action,
) =>
    state.copyWith(
      isLoading: true,
      isError: false,
    );

SubscriptionState _showSubscription(
  SubscriptionState state,
  ShowSubscriptionAction action,
) =>
    state.copyWith(
      isLoading: false,
      isError: false,
      hasPremium: action.status,
    );

SubscriptionState _errorSubscription(
  SubscriptionState state,
  ErrorSubscriptionAction action,
) =>
    state.copyWith(
      isLoading: false,
      isError: true,
      errorMessage: action.message,
    );
