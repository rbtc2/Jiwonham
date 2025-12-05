// 공고 추가/수정 화면
// 새 공고를 추가하거나 기존 공고를 수정하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AddEditApplicationScreen extends StatefulWidget {
  const AddEditApplicationScreen({super.key});

  @override
  State<AddEditApplicationScreen> createState() =>
      _AddEditApplicationScreenState();
}

class _AddEditApplicationScreenState extends State<AddEditApplicationScreen> {
  // Phase 1: 필수 입력 필드 컨트롤러
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _applicationLinkController =
      TextEditingController();
  DateTime? _deadline;

  // Phase 2: 선택 입력 필드 컨트롤러
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  DateTime? _announcementDate;

  @override
  void dispose() {
    _companyNameController.dispose();
    _applicationLinkController.dispose();
    _positionController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addApplication),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 저장 로직
            },
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 1: 필수 입력 필드
            _buildRequiredFields(context),
            const SizedBox(height: 24),

            // Phase 2: 선택 입력 필드
            _buildOptionalFields(context),
            const SizedBox(height: 24),

            // Phase 3: 동적 추가 기능
            _buildDynamicFields(context),
          ],
        ),
      ),
    );
  }

  // Phase 1: 필수 입력 필드 섹션
  Widget _buildRequiredFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 회사명 입력
        _buildTextField(
          context,
          label: AppStrings.companyNameRequired,
          controller: _companyNameController,
          icon: Icons.business,
          hintText: '회사명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 지원서 링크 입력
        _buildLinkField(context),
        const SizedBox(height: 24),

        // 서류 마감일 선택
        _buildDateField(
          context,
          label: AppStrings.deadlineRequired,
          icon: Icons.calendar_today,
          selectedDate: _deadline,
          onDateSelected: (date) {
            setState(() {
              _deadline = date;
            });
          },
        ),
      ],
    );
  }

  // 텍스트 입력 필드
  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  // 링크 입력 필드 (링크 테스트 버튼 포함)
  Widget _buildLinkField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.applicationLinkRequired,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _applicationLinkController,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                // TODO: 링크 테스트 로직
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text(AppStrings.testLink),
            ),
          ],
        ),
      ],
    );
  }

  // 날짜 선택 필드
  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required IconData icon,
    DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('ko', 'KR'),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}'
                      : AppStrings.selectDate,
                  style: TextStyle(
                    color: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Phase 2: 선택 입력 필드 섹션
  Widget _buildOptionalFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 직무명 입력
        _buildTextField(
          context,
          label: AppStrings.position,
          controller: _positionController,
          icon: Icons.work_outline,
          hintText: '직무명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 서류 발표일 선택
        _buildDateFieldWithNotification(
          context,
          label: AppStrings.announcementDate,
          icon: Icons.campaign,
          selectedDate: _announcementDate,
          onDateSelected: (date) {
            setState(() {
              _announcementDate = date;
            });
          },
        ),
        const SizedBox(height: 24),

        // 기타 메모 입력
        _buildMemoField(context),
      ],
    );
  }

  // 날짜 선택 필드 (알림 설정 포함)
  Widget _buildDateFieldWithNotification(
    BuildContext context, {
    required String label,
    required IconData icon,
    DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (picked != null) {
                    onDateSelected(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}'
                            : AppStrings.selectDate,
                        style: TextStyle(
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // TODO: 알림 설정 다이얼로그
              },
              icon: const Icon(Icons.notifications_outlined),
              tooltip: '알림 설정',
            ),
          ],
        ),
      ],
    );
  }

  // 메모 입력 필드 (여러 줄)
  Widget _buildMemoField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_outlined, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.memo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '메모를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  // Phase 3: 동적 추가 기능 섹션
  Widget _buildDynamicFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 다음 전형 일정 섹션
        _buildNextStagesSection(context),
        const SizedBox(height: 24),

        // 자기소개서 문항 섹션
        _buildCoverLetterQuestionsSection(context),
      ],
    );
  }

  // 다음 전형 일정 섹션
  Widget _buildNextStagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.nextStage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 일정 추가 로직
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addStage),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // TODO: 일정 목록 표시
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '일정을 추가하려면 [+ 일정 추가] 버튼을 누르세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 자기소개서 문항 섹션
  Widget _buildCoverLetterQuestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.description, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.coverLetterQuestions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 문항 추가 로직
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // TODO: 문항 목록 표시
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '문항을 추가하려면 [+ 문항 추가] 버튼을 누르세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
