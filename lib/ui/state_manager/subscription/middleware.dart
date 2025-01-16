import 'package:redux/redux.dart';
import 'package:scan_doc/data/services/subscription_service.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/state_manager/subscription/action.dart';

class SubscriptionMiddleware implements MiddlewareClass<AppState> {
  final SubscriptionService subscriptionService;

  SubscriptionMiddleware({required this.subscriptionService});

  @override
  call(store, action, next) {
    if (action is LoadSubscriptionAction) {
      Future(() async {
        final status = await subscriptionService.hasPremiumAccess();
        store.dispatch(ShowSubscriptionAction(status: status));
      });
    }
    if (action is PurchaseSubscriptionAction) {
      Future(() async {
        action.onLoad();
        final result = await subscriptionService.purchase(action.productId);
        action.onFinish();
        if (result.error == null) {
          store.dispatch(LoadSubscriptionAction());
        } else {
          action.onError('Сonnection error');
        }
      });
    }
    if (action is RestoreSubscriptionAction) {
      Future(() async {
        action.onLoad();
        final result = await subscriptionService.restore();
        action.onFinish();
        if (result.error == null) {
          store.dispatch(LoadSubscriptionAction());
        } else {
          action.onError('Сonnection error');
        }
      });
    }
    next(action);
  }
}
