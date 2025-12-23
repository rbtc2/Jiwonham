// 공고 목록 뷰 위젯
// 로딩, 에러, 빈 상태, 콘텐츠를 모두 관리하는 통합 위젯

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import 'application_list_loading.dart';
import 'application_list_error.dart';
import 'application_list_content.dart';
import 'empty_application_list.dart';

class ApplicationListView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Application> applications;
  final ApplicationStatus status;
  final bool isSelectionMode;
  final Set<String> selectedApplicationIds;
  final bool hasActiveFilters;
  final String statusText;
  final VoidCallback onRetry;
  final Future<void> Function()? onRefresh;
  final VoidCallback onApplicationChanged;
  final Function(String) onSelectionToggled;
  final Function(String) onLongPress;
  final VoidCallback onResetFilters;

  const ApplicationListView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.applications,
    required this.status,
    required this.isSelectionMode,
    required this.selectedApplicationIds,
    required this.hasActiveFilters,
    required this.statusText,
    required this.onRetry,
    this.onRefresh,
    required this.onApplicationChanged,
    required this.onSelectionToggled,
    required this.onLongPress,
    required this.onResetFilters,
  });

  Widget _buildContent(BuildContext context) {
    // 로딩 상태
    if (isLoading) {
      return const ApplicationListLoading();
    }

    // 에러 상태
    if (errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ApplicationListError(
            errorMessage: errorMessage!,
            onRetry: onRetry,
          ),
        ),
      );
    }

    // 빈 목록 상태
    if (applications.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: EmptyApplicationList(
            tabName: statusText,
            hasFilters: hasActiveFilters,
            onResetFilters: onResetFilters,
          ),
        ),
      );
    }

    // 정상 목록 표시
    return ApplicationListContent(
      applications: applications,
      isSelectionMode: isSelectionMode,
      selectedApplicationIds: selectedApplicationIds,
      onApplicationChanged: onApplicationChanged,
      onSelectionToggled: onSelectionToggled,
      onLongPress: onLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    // 새로고침 기능이 있으면 RefreshIndicator로 감싸기
    if (onRefresh != null && !isLoading) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}

