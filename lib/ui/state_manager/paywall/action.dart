import 'package:scan_doc/data/models/paywalls/paywall.dart';

abstract class PaywallListAction {}

class LoadPaywallListAction extends PaywallListAction {}

class ShowPaywallListAction extends PaywallListAction {
  final List<Paywall> paywalls;

  ShowPaywallListAction({required this.paywalls});
}

class ErrorPaywallListAction extends PaywallListAction {
  final String message;

  ErrorPaywallListAction({required this.message});
}
