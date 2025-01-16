import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gaimon/gaimon.dart';
import 'package:scan_doc/domain/di/get_it_services.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/screens/onboarding/onboarding_screen.dart';
import 'package:scan_doc/ui/state_manager/paywall/action.dart';
import 'package:scan_doc/ui/state_manager/paywall/state.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:scan_doc/ui/state_manager/subscription/action.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallData {
  final String name;
  final double summa;
  final String icon;

  PaywallData({
    required this.name,
    required this.summa,
    required this.icon,
  });
}

class GetPremiumScreen extends StatefulWidget {
  const GetPremiumScreen({super.key});

  @override
  State<GetPremiumScreen> createState() => _GetPremiumScreenState();
}

class _GetPremiumScreenState extends State<GetPremiumScreen> {
  late PaywallData selectedPaywall;

  final items = [
    const _Item(
      title: 'No adds',
      color: AppColors.info,
      icon: CupertinoIcons.tv_fill,
    ),
    const _Item(
      title: 'Pass protected folders',
      color: AppColors.success,
      icon: CupertinoIcons.folder_fill,
    ),
    const _Item(
      title: 'All editing options',
      color: AppColors.secondary,
      icon: CupertinoIcons.star_fill,
    ),
    const _Item(
      title: 'Custom folders',
      color: AppColors.primaryGrad1,
      icon: CupertinoIcons.cube_box_fill,
    ),
  ];

  final paywalls = [
    PaywallData(name: 'Weekly', summa: 4.99, icon: '👑'),
    PaywallData(name: 'Monthly', summa: 19.99, icon: '🔥'),
    PaywallData(name: 'Yearly', summa: 190.99, icon: '🚀'),
  ];

  @override
  void initState() {
    super.initState();
    selectedPaywall = paywalls.first;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Scanning PRO',
                        style: TextStyle(
                          fontSize: 40,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: Navigator.of(context).pop,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unlock new Features!',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            StoreConnector<AppState, PaywallListState>(
              converter: (store) => store.state.paywallListState,
              builder: (context, state) {
                if (state.isLoading) {
                  return Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                if (state.isError || state.paywalls.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
                    child: CupertinoAlertDialog(
                      title: const Text("Some Error"),
                      content: Text(
                        state.isError ? state.errorMessage : 'Paywalls list is empty',
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            final store = StoreProvider.of<AppState>(
                              context,
                              listen: false,
                            );
                            store.dispatch(LoadPaywallListAction());
                          },
                          isDefaultAction: true,
                          child: const Text(
                            'Refresh',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var item in items) ...[
                            item,
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SizedBox(width: 16),
                          for (var paywall in paywalls) ...[
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: selectedPaywall == paywall
                                        ? LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primary.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    border: Border.all(
                                      color: selectedPaywall == paywall
                                          ? Colors.transparent
                                          : AppColors.textPrimary.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: _Block(
                                    paywall: paywall,
                                    active: selectedPaywall == paywall,
                                    onTap: () => setState(() => selectedPaywall = paywall),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientButton(
                        onPressed: () {},
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        child: const Text(
                          'Get Premium',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButtonOnbg(
                          text: 'Terms of Use',
                          onTap: () => launchUrl(
                            Uri.parse(getItService.configService.termsLink),
                            mode: LaunchMode.inAppWebView,
                          ),
                        ),
                        TextButtonOnbg(
                          text: 'Privacy Policy',
                          onTap: () => launchUrl(
                            Uri.parse(getItService.configService.privacyLink),
                            mode: LaunchMode.inAppWebView,
                          ),
                        ),
                        TextButtonOnbg(
                          text: 'Restore',
                          onTap: () {
                            final store = StoreProvider.of<AppState>(context, listen: false);
                            store.dispatch(RestoreSubscriptionAction(
                              onFinish: Navigator.of(context).pop,
                              onError: (e) {
                                showDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                    title: const Text("Some Error"),
                                    content: Text(e),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        onPressed: Navigator.of(context).pop,
                                        isDefaultAction: true,
                                        child: const Text(
                                          "Ok",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onLoad: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const Center(
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ));
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final PaywallData paywall;
  final bool active;
  final Function() onTap;

  const _Block({
    super.key,
    required this.paywall,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Gaimon.selection();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.black.withOpacity(.1),
        ),
        width: 200,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              paywall.icon,
              style: const TextStyle(fontSize: 45),
            ),
            const SizedBox(height: 20),
            Text(
              '${paywall.summa}\$',
              style: const TextStyle(
                fontSize: 40,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              paywall.name,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (active)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 37,
                ),
                child: const Text(
                  '3 Days Free',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _Item({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
