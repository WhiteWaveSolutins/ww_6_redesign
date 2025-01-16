import 'package:scan_doc/ui/state_manager/document/action.dart';
import 'package:scan_doc/ui/state_manager/document/reducer.dart';
import 'package:scan_doc/ui/state_manager/folder/action.dart';
import 'package:scan_doc/ui/state_manager/folder/reducer.dart';
import 'package:scan_doc/ui/state_manager/paywall/action.dart';
import 'package:scan_doc/ui/state_manager/paywall/reducer.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/state_manager/subscription/action.dart';
import 'package:scan_doc/ui/state_manager/subscription/reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is FolderListAction) {
    final nextState = folderListReducer(state.folderListState, action);
    return state.copyWith(folderListState: nextState);
  } else if (action is DocumentListAction) {
    final nextState = documentListReducer(state.documentListState, action);
    return state.copyWith(documentListState: nextState);
  } else if (action is SubscriptionAction) {
    final nextState = subscriptionReducer(state.subscriptionState, action);
    return state.copyWith(subscriptionState: nextState);
  } else if (action is PaywallListAction) {
    final nextState = paywallListReducer(state.paywallListState, action);
    return state.copyWith(paywallListState: nextState);
  }
  return state;
}
