import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scan_doc/domain/di/locator.dart';
import 'package:scan_doc/route.dart';
import 'package:scan_doc/ui/screens/splash/splash_screen.dart';
import 'package:scan_doc/ui/state_manager/store.dart';
import 'package:talker/talker.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'domain/di/get_it_services.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: bindings);
  HttpOverrides.global = MyHttpOverrides();
  final locator = LocatorService();
  await locator.configService.init();
  locator.init();
  addLifecycleHandler();

  FlutterError.onError = (details) {
    Talker().logCustom(
      TalkerLog(
        details.exceptionAsString(),
        title: 'ERROR FLUTTER',
        logLevel: LogLevel.critical,
        stackTrace: details.stack,
      ),
    );
  };

  runApp(
    AppInfo(
      data: await AppInfoData.get(),
      child: PDFScanner(locator: locator),
    ),
  );
}

class PDFScanner extends StatelessWidget {
  final LocatorService locator;

  const PDFScanner({
    super.key,
    required this.locator,
  });

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: StoreProvider<AppState>(
        store: locator.store,
        child: CupertinoApp(
          navigatorKey: locator.navigatorKey,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          title: 'PDFScanSmart',
          locale: const Locale('en'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}

void addLifecycleHandler() {
  WidgetsBinding.instance.addObserver(
    AppLifecycleListener(
      onDetach: getItService.configService.closeClient,
    ),
  );
}
