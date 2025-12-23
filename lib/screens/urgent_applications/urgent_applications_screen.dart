// 마감 임박 공고 화면
// D-7 이내의 마감 임박 공고만 보여주는 전용 화면

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../services/storage_service.dart';
import '../application_detail/application_detail_screen.dart';
import '../../widgets/d_day_badge.dart';

// Phase 1: 마감 임박 공고 전용 화면 생성
class UrgentApplicationsScreen extends StatefulWidget {
  const UrgentApplicationsScreen({super.key});

  @override
  State<UrgentApplicationsScreen> createState() =>
      _UrgentApplicationsScreenState();
}

class _UrgentApplicationsScreenState extends State<UrgentApplicationsScreen>
    with WidgetsBindingObserver {
  // Phase 1: 실제 데이터 관리
  // ignore: unused_field (전체 공고 데이터 저장용, 확장성 고려)
  List<Application> _applications = [];
  List<Application> _urgentApplications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Phase 5: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    // Phase 1: 데이터 로드
    _loadApplications();
  }

  @override
  void dispose() {
    // Phase 5: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Phase 5: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _loadApplications();
    }
  }

  // Phase 1: 데이터 로드 메서드
  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      // 보관함 제외한 공고만 가져오기 (활성 공고만)
      final applications = await storageService.getActiveApplications();

      if (!mounted) return;

      // Phase 1: 마감 임박 공고 필터링 (D-7 이내, 마감일 지나지 않은 공고)
      final urgentApps = applications
          .where((app) => app.isUrgent && !app.isDeadlinePassed)
          .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

      setState(() {
        _applications = applications;
        _urgentApplications = urgentApps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Phase 5: 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    if (mounted) {
      _loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.urgentApplications),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Phase 6: Pull-to-refresh 기능
              onRefresh: _loadApplications,
              child: _buildContent(),
            ),
    );
  }

  // Phase 2: 화면 UI 기본 구조 구성
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase 2: 제목 및 부제목
          Text(
            AppStrings.urgentApplications,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          // Phase 6: 공고 개수 표시
          Text(
            'D-7 이내 · 총 ${_urgentApplications.length}개',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Phase 2: 빈 상태 처리 또는 공고 목록 (Phase 3에서 구현)
          if (_urgentApplications.isEmpty)
            _buildEmptyState()
          else
            _buildApplicationsList(),
        ],
      ),
    );
  }

  // Phase 2: 빈 상태 처리
  Widget _buildEmptyState() {
    return Card(
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
    );
  }

  // Phase 3: 공고 목록 표시 기능
  Widget _buildApplicationsList() {
    return Column(
      children: [
        ..._urgentApplications.map((app) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUrgentApplicationCard(context, app),
          );
        }),
      ],
    );
  }

  // Phase 3: 마감 임박 공고 카드
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
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ApplicationDetailScreen(application: application),
            ),
          );
          // Phase 5: 상태 변경 시 데이터 새로고침
          if (result == true) {
            _loadApplications();
          }
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
                          // Phase 3: 지원서 링크 열기
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
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationDetailScreen(
                              application: application,
                            ),
                          ),
                        );
                        // Phase 5: 상태 변경 시 데이터 새로고침
                        if (result == true) {
                          _loadApplications();
                        }
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

  // Phase 3: 링크 열기 에러 메시지 표시
  void _showLinkErrorSnackBar(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('링크를 열 수 없습니다: $error'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

