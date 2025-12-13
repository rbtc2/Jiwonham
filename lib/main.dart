import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_navigation.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'services/storage_service.dart';

void main() async {
  // 처리되지 않은 에러를 잡기 위한 Zone 설정
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // StorageService 초기화
      await StorageService().init();
      runApp(const MyApp());
    } catch (e, stackTrace) {
      // 초기화 중 에러 발생 시 로그 출력
      debugPrint('앱 초기화 중 에러 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
      // 에러가 발생해도 앱은 실행 시도
      runApp(const MyApp());
    }
  }, (error, stackTrace) {
    // 처리되지 않은 에러를 잡아서 로그 출력
    debugPrint('처리되지 않은 에러: $error');
    debugPrint('스택 트레이스: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
