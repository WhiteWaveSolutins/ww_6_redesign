
import 'package:apphud/apphud.dart';
import 'package:apphud/models/apphud_models/apphud_composite_model.dart';
import 'package:apphud/models/apphud_models/composite/apphud_purchase_result.dart';
import 'package:scan_doc/data/models/answer/answer.dart';
import 'package:scan_doc/data/models/paywalls/paywall.dart';
import 'package:scan_doc/data/services/config_service.dart';
import 'package:talker/talker.dart';

class SubscriptionService {
  final ConfigService configService;

  //late ApphudUser _user;
  SubscriptionService({required this.configService}) {
    _init();
  }

  void _init() async {
    await Apphud.start(apiKey: configService.apphudKey);
    //getMainPaywall();
  }

  Future<Answer<List<Paywall>>> getPaywalls() async {
    try {
      final paywalls = await Apphud.paywalls();
      final data = paywalls!.paywalls
          .map(
            (e) => Paywall.fromJson(
              data: e.json ?? {},
              productId: e.products!.first.productId,
            ),
          )
          .toList();
      return Answer(data: data);
    } catch (e) {
      _log(message: 'Подписки $e');
      return Answer(error: e.toString());
    }
  }

  Future<Answer<Paywall>> getOnboardingPaywall() async {
    try {
      final paywalls = await Apphud.paywalls();
      final data = paywalls!.paywalls.first.json!;
      final paywall = Paywall.fromJson(
        data: data,
        productId: paywalls.paywalls.first.products!.first.productId,
      );
      return Answer(data: paywall);
    } catch (e) {
      _log(message: e.toString());
      return Answer(error: e.toString());
    }
  }

  Future<Answer<Paywall>> getMainPaywall() async {
    try {
      final paywalls = await Apphud.paywalls();
      final data = paywalls!.paywalls.last.json!;
      final paywall = Paywall.fromJson(
        data: data,
        productId: paywalls.paywalls.last.products!.first.productId,
      );
      return Answer(data: paywall);
    } catch (e) {
      _log(message: e.toString());
      return Answer(error: e.toString());
    }
  }

  Future<ApphudComposite> restore() async {
    try {
      final res = await Apphud.restorePurchases();
      return res;
    } catch (e) {
      _log(message: e.toString());
      rethrow;
    }
  }

  Future<ApphudPurchaseResult> purchase(String productId) async {
    try {
      final res = await Apphud.purchase(productId: productId);
      return res;
    } catch (e) {
      _log(message: e.toString());
      rethrow;
    }
  }

  Future<bool> hasPremiumAccess() async => await Apphud.hasPremiumAccess();
}

void _log({required String message}) {
  Talker().logCustom(
    TalkerLog(
      message,
      title: 'Subscription Error',
      logLevel: LogLevel.critical,
    ),
  );
}
