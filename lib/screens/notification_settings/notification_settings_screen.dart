// 설정 화면
// 알림, 프리미엄, 후원, 데이터 관리, 정보를 관리하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/modern_card.dart';
import '../../services/storage_service.dart';
import '../../widgets/dialogs/app_info_dialog.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // 스켈레톤 UI용 상태 (실제 기능 없음)
  bool _enableNotifications = true;
  bool _excludeArchivedFromStats = true;
  final bool _isPremium = false;
  int _applicationCount = 0; // 실제로는 StorageService에서 가져올 예정
  bool _settingsChanged = false; // 설정 변경 여부 추적

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadApplicationCount();
  }

  Future<void> _loadSettings() async {
    final storageService = StorageService();
    final excludeArchived = await storageService
        .getExcludeArchivedFromStatistics();
    if (mounted) {
      setState(() {
        _excludeArchivedFromStats = excludeArchived;
      });
    }
  }

  Future<void> _loadApplicationCount() async {
    // TODO: StorageService에서 공고 개수 가져오기
    setState(() {
      _applicationCount = 12; // 임시 값
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // 뒤로가기 시 설정 변경 여부를 결과로 반환
          Navigator.of(context).pop(_settingsChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.settings), elevation: 0),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 알림 설정 섹션
                _buildNotificationSection(context),
                const SizedBox(height: 24),

                // 프리미엄 섹션
                _buildPremiumSection(context),
                const SizedBox(height: 24),

                // 데이터 관리 섹션
                _buildDataManagementSection(context),
                const SizedBox(height: 24),

                // 정보 섹션
                _buildInfoSection(context),
                const SizedBox(height: 24),

                // 후원하기 섹션
                _buildDonationSection(context),
                // 하단 여백 추가
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 알림 설정 섹션
  Widget _buildNotificationSection(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.receiveNotification,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(AppStrings.receiveNotification),
            value: _enableNotifications,
            onChanged: (value) {
              // TODO: 실제 기능 구현
              setState(() {
                _enableNotifications = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.notificationDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Row(
              children: [
                const Icon(
                  Icons.archive_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(AppStrings.excludeArchivedFromStats),
              ],
            ),
            subtitle: Text(
              AppStrings.excludeArchivedFromStatsDescription,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            value: _excludeArchivedFromStats,
            onChanged: (value) async {
              final storageService = StorageService();
              final success = await storageService
                  .setExcludeArchivedFromStatistics(value);
              if (success && mounted) {
                setState(() {
                  _excludeArchivedFromStats = value;
                  _settingsChanged = true; // 설정 변경 표시
                });
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // 프리미엄 섹션
  Widget _buildPremiumSection(BuildContext context) {
    return ModernCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.premium,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isPremium)
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.alreadyPurchased,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 프리미엄 구매 기능 구현
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text('${AppStrings.purchasePremium} (₩1,000)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.block, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.removeAds,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.premiumDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // 후원하기 섹션
  Widget _buildDonationSection(BuildContext context) {
    return ModernCard(
      child: InkWell(
        onTap: () {
          // TODO: 후원 다이얼로그 표시
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_cafe,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.buyDeveloperCoffee,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.donationDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 데이터 관리 섹션
  Widget _buildDataManagementSection(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storage,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.dataManagement,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataManagementItem(
            context,
            icon: Icons.download,
            title: AppStrings.exportData,
            onTap: () {
              // TODO: 데이터 내보내기 기능 구현
            },
          ),
          const Divider(height: 1),
          _buildDataManagementItem(
            context,
            icon: Icons.delete_outline,
            title: AppStrings.deleteAllData,
            iconColor: AppColors.error,
            onTap: () {
              // TODO: 데이터 삭제 확인 다이얼로그 표시
            },
          ),
          const Divider(height: 1),
          _buildDataManagementItem(
            context,
            icon: Icons.description_outlined,
            title:
                '${AppStrings.savedApplications}: $_applicationCount${AppStrings.count}',
            isReadOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    VoidCallback? onTap,
    bool isReadOnly = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(title),
      trailing: isReadOnly
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
      onTap: isReadOnly ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }

  // 정보 섹션
  Widget _buildInfoSection(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.info,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.person_outline,
            title: AppStrings.developerInfo,
            onTap: () {
              AppInfoDialog.show(context);
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            context,
            icon: Icons.feedback_outlined,
            title: AppStrings.sendFeedback,
            onTap: () {
              // TODO: 피드백 보내기 기능 구현
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isReadOnly = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: isReadOnly
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
      onTap: isReadOnly ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}
