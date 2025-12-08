// 공고 추가/수정 화면
// 새 공고를 추가하거나 기존 공고를 수정하는 화면

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Phase 3: 다음 전형 일정 리스트
  final List<Map<String, dynamic>> _nextStages = [];

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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              onPressed: () async {
                await _testLink(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '메모를 입력하세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                _showAddStageDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addStage),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_nextStages.isEmpty)
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
          )
        else
          ...List.generate(_nextStages.length, (index) {
            return _buildStageItem(context, _nextStages[index], index);
          }),
      ],
    );
  }

  // 전형 일정 아이템
  Widget _buildStageItem(
    BuildContext context,
    Map<String, dynamic> stage,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage['type'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(stage['date'] as DateTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _showEditStageDialog(context, index);
              },
              icon: const Icon(Icons.edit, size: 20),
              tooltip: AppStrings.editStage,
            ),
            IconButton(
              onPressed: () {
                _showDeleteStageConfirmDialog(context, index);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              tooltip: AppStrings.deleteStage,
            ),
          ],
        ),
      ),
    );
  }

  // 일정 추가 다이얼로그
  void _showAddStageDialog(BuildContext context) {
    final typeController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(AppStrings.addStage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.stageType,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    hintText: AppStrings.stageTypeExample,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.stageDate,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
                      setDialogState(() {
                        selectedDate = picked;
                      });
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
                              ? _formatDate(selectedDate!)
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (typeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('전형 유형을 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('일정을 선택해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setState(() {
                  _nextStages.add({
                    'type': typeController.text.trim(),
                    'date': selectedDate!,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  // 일정 수정 다이얼로그
  void _showEditStageDialog(BuildContext context, int index) {
    final stage = _nextStages[index];
    final typeController = TextEditingController(text: stage['type'] as String);
    DateTime? selectedDate = stage['date'] as DateTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('일정 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.stageType,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    hintText: AppStrings.stageTypeExample,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.stageDate,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
                      setDialogState(() {
                        selectedDate = picked;
                      });
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
                              ? _formatDate(selectedDate!)
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (typeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('전형 유형을 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('일정을 선택해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setState(() {
                  _nextStages[index] = {
                    'type': typeController.text.trim(),
                    'date': selectedDate!,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  // 일정 삭제 확인 다이얼로그
  void _showDeleteStageConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nextStages.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
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
                Icon(
                  Icons.description,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
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

  // Phase 1: 링크 테스트 기능
  Future<void> _testLink(BuildContext context) async {
    final urlString = _applicationLinkController.text.trim();

    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크를 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // URL 형식 검증 및 수정
    Uri? uri;
    try {
      uri = Uri.parse(urlString);
      // http:// 또는 https://가 없으면 추가
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlString');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 URL 형식이 아닙니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // URL 열기
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('링크를 열 수 없습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크 열기 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
