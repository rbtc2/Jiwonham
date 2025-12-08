// 메인 네비게이션
// Bottom Navigation Bar를 포함한 메인 네비게이션 구조

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'home/home_screen.dart';
import 'applications/applications_screen.dart';
import 'calendar/calendar_screen.dart';
import 'statistics/statistics_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

// Phase 3: State 클래스를 public으로 변경하여 외부에서 접근 가능하게 함
class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Phase 3: ApplicationsScreen에 접근하기 위한 GlobalKey
  final GlobalKey<ApplicationsScreenState> _applicationsScreenKey =
      GlobalKey<ApplicationsScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Phase 3: ApplicationsScreen을 GlobalKey와 함께 생성
    _screens = [
      const HomeScreen(),
      ApplicationsScreen(key: _applicationsScreenKey),
      const CalendarScreen(),
      const StatisticsScreen(),
    ];
  }

  // Phase 3: ApplicationsScreen 새로고침 메서드
  void refreshApplicationsScreen() {
    _applicationsScreenKey.currentState?.refresh();
  }

  // Phase 4: 현재 탭 인덱스 설정 (외부에서 호출 가능)
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: AppStrings.navApplications,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: AppStrings.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: AppStrings.navStatistics,
          ),
        ],
      ),
    );
  }
}
