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
import '../../widgets/d_day_badge.dart';

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
      // 보관함 제외한 공고만 가져오기
      final applications = await storageService.getActiveApplications();

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

  // Phase 6: 마감 임박 공고 (D-3 이내)
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
            Icon(Icons.work_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
        ],
        elevation: 0,
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
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addNewApplication),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Phase 6: 통계 섹션 (실제 데이터 사용)
  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.todayStatistics,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                AppStrings.totalApplications,
                _totalApplications.toString(),
                AppColors.primary,
                Icons.description_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppStrings.inProgress,
                _inProgressCount.toString(),
                AppColors.warning,
                Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppStrings.passed,
                _passedCount.toString(),
                AppColors.success,
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 통계 카드
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // Phase 6: 마감 임박 공고 섹션 (실제 데이터 사용)
  Widget _buildUrgentApplicationsSection(BuildContext context) {
    final urgentApps = _urgentApplications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.urgentApplications,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Phase 4: 공고 목록 화면으로 이동
                final mainNavigationState = context
                    .findAncestorStateOfType<State<StatefulWidget>>();
                if (mainNavigationState != null &&
                    mainNavigationState.runtimeType.toString().contains(
                      'MainNavigationState',
                    )) {
                  // ignore: avoid_dynamic_calls
                  (mainNavigationState as dynamic).setCurrentIndex(1);
                }
              },
              child: const Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.urgentApplicationsSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (urgentApps.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '마감 임박 공고가 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...urgentApps.take(5).map((app) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailScreen(
                application: application,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DDayBadge(deadline: application.deadline),
                  const Spacer(),
                  if (application.notificationSettings.deadlineNotification)
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.warning,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.companyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (application.position != null &&
                  application.position!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        application.position!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    deadlineText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (application.applicationLink != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Phase 6: 지원서 링크 열기
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
                        child: const Text(AppStrings.apply),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationDetailScreen(
                              application: application,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(AppStrings.viewDetail),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Phase 6: 오늘의 일정 섹션 (실제 데이터 사용)
  Widget _buildTodayScheduleSection(BuildContext context) {
    final schedules = _todaySchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.todaySchedule,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (schedules.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘 일정이 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...schedules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final schedule = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        InkWell(
                          onTap: () {
                            final app = schedule['application'] as Application;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApplicationDetailScreen(
                                  application: app,
                                ),
                              ),
                            );
                          },
                          child: _buildScheduleItem(
                            context,
                            schedule['icon'] as IconData,
                            schedule['type'] as String,
                            schedule['company'] as String,
                            schedule['timeOrDday'] as String?,
                            schedule['color'] as Color,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                company,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (timeOrDday != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeOrDday,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
