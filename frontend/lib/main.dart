import 'package:fair_front/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:provider/provider.dart';
import 'controllers/map_controller.dart';
import 'controllers/poi_controller.dart';
import 'controllers/user_controller.dart';
import 'providers/fair_result_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/loading_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await initializeDateFormatting('ko_KR', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // 세로 고정

  await KakaoMapSdk.instance.initialize(
    dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoiController()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  MapController(poiController: context.read<PoiController>()),
        ),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => FairResultProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const FairMeetingApp(),
    ),
  );
}

class FairMeetingApp extends StatelessWidget {
  const FairMeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context); // 언어 상태 가져오기

    return MaterialApp(
      title: 'Fair Meeting',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      // 현재 로케일 반영
      supportedLocales: const [Locale('ko'), Locale('en')],
      // 다국어 지원
      localizationsDelegates: const [
        // 앱 로컬라이제이션 적용
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF121212),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const AppStart(),
      routes: {'/main': (context) => MainmenuScreen()},
    );
  }
}
