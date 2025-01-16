import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scan_doc/ui/state_manager/document/state.dart';
import 'package:scan_doc/ui/state_manager/folder/state.dart';
import 'package:scan_doc/ui/state_manager/paywall/state.dart';
import 'package:scan_doc/ui/state_manager/subscription/state.dart';

part 'store.freezed.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    required FolderListState folderListState,
    required DocumentListState documentListState,
    required SubscriptionState subscriptionState,
    required PaywallListState paywallListState,
  }) = _AppState;
}
