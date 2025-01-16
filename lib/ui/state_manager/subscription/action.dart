abstract class SubscriptionAction {}

class LoadSubscriptionAction extends SubscriptionAction {}

class RestoreSubscriptionAction extends SubscriptionAction {
  final Function() onLoad;
  final Function() onFinish;
  final Function(String error) onError;

  RestoreSubscriptionAction({
    required this.onLoad,
    required this.onFinish,
    required this.onError,
  });
}

class PurchaseSubscriptionAction extends SubscriptionAction {
  final String productId;
  final Function() onLoad;
  final Function() onFinish;
  final Function(String error) onError;

  PurchaseSubscriptionAction({
    required this.productId,
    required this.onLoad,
    required this.onFinish,
    required this.onError,
  });
}

class ShowSubscriptionAction extends SubscriptionAction {
  final bool status;

  ShowSubscriptionAction({required this.status});
}

class ErrorSubscriptionAction extends SubscriptionAction {
  final String message;

  ErrorSubscriptionAction({required this.message});
}
