// 홈 화면
// 통계 요약, 마감 임박 공고, 오늘의 일정을 보여주는 메인 화면

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import '../notification_settings/notification_settings_screen.dart';
import '../application_detail/application_detail_screen.dart';
import '../urgent_applications/urgent_applications_screen.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/modern_stat_card.dart';
import '../../widgets/modern_section_header.dart';
import '../../widgets/modern_card.dart';

// Phase 4: StatefulWidget으로 변경하여 새로고침 기능 추가
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Phase 6: 실제 데이터 관리
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Phase 6: 데이터 로드
    _loadApplications();
  }

  // Phase 6: 데이터 로드 메서드
  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();

      if (!mounted) return;

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Phase 4: 새로고침 메서드
  void refresh() {
    _loadApplications();
  }

  // MainNavigation을 통해 ApplicationsScreen 새로고침
  void _refreshApplicationsScreen() {
    if (!mounted) return;
    try {
      final mainNavigationState = context
          .findAncestorStateOfType<State<StatefulWidget>>();
      if (mainNavigationState != null &&
          mainNavigationState.runtimeType.toString().contains(
            'MainNavigationState',
          )) {
        // ignore: avoid_dynamic_calls
        (mainNavigationState as dynamic).refreshApplicationsScreen();
      }
    } catch (e) {
      // 에러 발생 시 무시 (이미 WidgetsBindingObserver로 자동 새로고침됨)
    }
  }

  // 링크 열기 에러 메시지 표시
  void _showLinkErrorSnackBar(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('링크를 열 수 없습니다: $error'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // Phase 6: 통계 계산
  int get _totalApplications => _applications.length;
  int get _inProgressCount => _applications
      .where((app) => app.status == ApplicationStatus.inProgress)
      .length;
  int get _passedCount => _applications
      .where((app) => app.status == ApplicationStatus.passed)
      .length;

  // Phase 6: 마감 임박 공고 (D-7 이내)
  List<Application> get _urgentApplications {
    return _applications
        .where((app) => app.isUrgent && !app.isDeadlinePassed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // Phase 6: 오늘의 일정
  List<Map<String, dynamic>> get _todaySchedules {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final schedules = <Map<String, dynamic>>[];

    for (final app in _applications) {
      // 마감일이 오늘인 경우
      final deadlineDate = DateTime(
        app.deadline.year,
        app.deadline.month,
        app.deadline.day,
      );
      if (deadlineDate == todayDate) {
        schedules.add({
          'type': '마감일',
          'icon': Icons.event_busy,
          'color': AppColors.error,
          'company': app.companyName,
          'position': app.position,
          'timeOrDday': 'D-0',
          'application': app,
        });
      }

      // 발표일이 오늘인 경우
      if (app.announcementDate != null) {
        final announcementDate = DateTime(
          app.announcementDate!.year,
          app.announcementDate!.month,
          app.announcementDate!.day,
        );
        if (announcementDate == todayDate) {
          schedules.add({
            'type': '발표일',
            'icon': Icons.campaign,
            'color': AppColors.primary,
            'company': app.companyName,
            'position': app.position,
            'timeOrDday': null,
            'application': app,
          });
        }
      }

      // 다음 전형 일정이 오늘인 경우
      for (final stage in app.nextStages) {
        final stageDate = DateTime(
          stage.date.year,
          stage.date.month,
          stage.date.day,
        );
        if (stageDate == todayDate) {
          schedules.add({
            'type': stage.type,
            'icon': Icons.phone_in_talk,
            'color': AppColors.info,
            'company': app.companyName,
            'position': app.position,
            'timeOrDday': stage.date.hour != 0 || stage.date.minute != 0
                ? '${stage.date.hour.toString().padLeft(2, '0')}:${stage.date.minute.toString().padLeft(2, '0')}'
                : null,
            'application': app,
          });
        }
      }
    }

    // 시간순으로 정렬
    schedules.sort((a, b) {
      final appA = a['application'] as Application;
      final appB = b['application'] as Application;
      return appA.deadline.compareTo(appB.deadline);
    });

    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.work_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
              tooltip: AppStrings.notificationSettings,
            ),
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오늘의 통계 섹션
                  _buildStatisticsSection(context),
                  const SizedBox(height: 24),

                  // 마감 임박 공고 섹션
                  _buildUrgentApplicationsSection(context),
                  const SizedBox(height: 24),

                  // 오늘의 일정 섹션
                  _buildTodayScheduleSection(context),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Phase 3: 새 공고 추가 후 결과 확인
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditApplicationScreen(),
            ),
          );

          // Phase 4: 저장 성공 시 ApplicationsScreen 및 HomeScreen 새로고침
          if (result == true) {
            // Phase 6: HomeScreen 새로고침
            if (mounted) {
              _loadApplications();
              _refreshApplicationsScreen();
            }
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          '공고 추가',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Phase 6: 통계 섹션 (실제 데이터 사용)
  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: AppStrings.todayStatistics,
          icon: Icons.analytics_outlined,
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                label: AppStrings.totalApplications,
                value: _totalApplications.toString(),
                color: AppColors.primary,
                icon: Icons.description_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernStatCard(
                label: AppStrings.inProgress,
                value: _inProgressCount.toString(),
                color: AppColors.warning,
                icon: Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernStatCard(
                label: AppStrings.passed,
                value: _passedCount.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Phase 6: 마감 임박 공고 섹션 (실제 데이터 사용)
  Widget _buildUrgentApplicationsSection(BuildContext context) {
    final urgentApps = _urgentApplications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: AppStrings.urgentApplications,
          subtitle: AppStrings.urgentApplicationsSubtitle,
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          action: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UrgentApplicationsScreen(),
                ),
              );
            },
            child: const Text(AppStrings.viewAll),
          ),
        ),
        const SizedBox(height: 20),
        if (urgentApps.isEmpty)
          ModernCard(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '마감 임박 공고가 없습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '모든 공고가 여유롭게 관리되고 있어요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...urgentApps.take(5).map((app) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildUrgentApplicationCard(context, app),
            );
          }),
      ],
    );
  }

  // Phase 6: 마감 임박 공고 카드 (실제 데이터 사용)
  Widget _buildUrgentApplicationCard(
    BuildContext context,
    Application application,
  ) {
    final deadlineText =
        application.deadline.hour != 0 || application.deadline.minute != 0
        ? '${application.deadline.year}.${application.deadline.month.toString().padLeft(2, '0')}.${application.deadline.day.toString().padLeft(2, '0')} ${application.deadline.hour.toString().padLeft(2, '0')}:${application.deadline.minute.toString().padLeft(2, '0')}'
        : '${application.deadline.year}.${application.deadline.month.toString().padLeft(2, '0')}.${application.deadline.day.toString().padLeft(2, '0')}';

    return ModernCard(
      padding: const EdgeInsets.all(20.0),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ApplicationDetailScreen(application: application),
          ),
        );
        if (result == true) {
          _loadApplications();
          _refreshApplicationsScreen();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DDayBadge(deadline: application.deadline),
              const Spacer(),
              if (application.notificationSettings.deadlineNotification)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  application.companyName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          if (application.position != null &&
              application.position!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 36),
                Icon(
                  Icons.work_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    application.position!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 36),
              Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                deadlineText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (application.applicationLink != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final link = application.applicationLink!;
                      try {
                        Uri uri = Uri.parse(link);
                        if (!uri.hasScheme) {
                          uri = Uri.parse('https://$link');
                        }
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        _showLinkErrorSnackBar(e);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.apply,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationDetailScreen(
                          application: application,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadApplications();
                      _refreshApplicationsScreen();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.viewDetail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Phase 6: 오늘의 일정 섹션 (실제 데이터 사용)
  Widget _buildTodayScheduleSection(BuildContext context) {
    final schedules = _todaySchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: AppStrings.todaySchedule,
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: 20),
        if (schedules.isEmpty)
          ModernCard(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오늘 일정이 없습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘은 여유롭게 준비하세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ModernCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ...schedules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final schedule = entry.value;
                  return Column(
                    children: [
                      if (index > 0) 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      InkWell(
                        onTap: () async {
                          final app = schedule['application'] as Application;
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ApplicationDetailScreen(application: app),
                            ),
                          );
                          if (result == true) {
                            _loadApplications();
                            _refreshApplicationsScreen();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildScheduleItem(
                            context,
                            schedule['icon'] as IconData,
                            schedule['type'] as String,
                            schedule['company'] as String,
                            schedule['timeOrDday'] as String?,
                            schedule['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  // 일정 아이템
  Widget _buildScheduleItem(
    BuildContext context,
    IconData icon,
    String type,
    String company,
    String? timeOrDday,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                company,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (timeOrDday != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeOrDday,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
