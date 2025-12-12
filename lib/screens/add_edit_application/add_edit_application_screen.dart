// 공고 추가/수정 화면
// 새 공고를 추가하거나 기존 공고를 수정하는 화면

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/cover_letter_question.dart';
import '../../models/notification_settings.dart';
import '../../models/application.dart';
import '../../models/next_stage.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
// Phase 1: 폼 필드 위젯 import
import '../../widgets/form_fields/labeled_text_field.dart';
import '../../widgets/form_fields/link_text_field.dart';
import '../../widgets/form_fields/date_time_field.dart';
// Phase 2: 다이얼로그 위젯 import
import '../../widgets/dialogs/add_stage_dialog.dart';
import '../../widgets/dialogs/edit_stage_dialog.dart';
import '../../widgets/dialogs/delete_stage_confirm_dialog.dart';
import '../../widgets/dialogs/add_question_dialog.dart';
import '../../widgets/dialogs/edit_question_dialog.dart';
import '../../widgets/dialogs/delete_question_confirm_dialog.dart';
import '../../widgets/dialogs/notification_settings_dialog.dart';
import '../../utils/date_utils.dart' show formatDate;

class AddEditApplicationScreen extends StatefulWidget {
  final Application? application; // Phase 7: 수정 모드용 기존 Application

  const AddEditApplicationScreen({super.key, this.application});

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

  // Phase 2: 자기소개서 문항 리스트
  final List<CoverLetterQuestion> _coverLetterQuestions = [];

  // Phase 3: 유효성 검사 에러 메시지
  String? _companyNameError;
  String? _applicationLinkError;
  String? _deadlineError;

  // Phase 4: 알림 설정
  NotificationSettings? _deadlineNotificationSettings;
  NotificationSettings? _announcementNotificationSettings;

  // 시간 포함 여부 및 시간 선택
  bool _deadlineIncludeTime = false;
  bool _announcementDateIncludeTime = false;
  TimeOfDay? _deadlineTime;
  TimeOfDay? _announcementDateTime;

  // Phase 7: 수정 모드용 ID
  String? _editingApplicationId;

  @override
  void initState() {
    super.initState();
    // Phase 7: 기존 Application이 있으면 데이터 로드
    if (widget.application != null) {
      _loadApplicationData(widget.application!);
    }
  }

  // Phase 7: 기존 Application 데이터 로드
  void _loadApplicationData(Application application) {
    _editingApplicationId = application.id;
    _companyNameController.text = application.companyName;
    _applicationLinkController.text = application.applicationLink ?? '';
    _deadline = application.deadline;
    _positionController.text = application.position ?? '';
    _announcementDate = application.announcementDate;
    _memoController.text = application.memo ?? '';

    // 시간 정보 추출
    if (_deadline != null) {
      final deadlineHour = _deadline!.hour;
      final deadlineMinute = _deadline!.minute;
      if (deadlineHour != 0 || deadlineMinute != 0) {
        _deadlineIncludeTime = true;
        _deadlineTime = TimeOfDay(hour: deadlineHour, minute: deadlineMinute);
      }
    }
    if (_announcementDate != null) {
      final announcementHour = _announcementDate!.hour;
      final announcementMinute = _announcementDate!.minute;
      if (announcementHour != 0 || announcementMinute != 0) {
        _announcementDateIncludeTime = true;
        _announcementDateTime = TimeOfDay(
          hour: announcementHour,
          minute: announcementMinute,
        );
      }
    }

    // NextStage 리스트 로드
    _nextStages.clear();
    for (final stage in application.nextStages) {
      _nextStages.add({'type': stage.type, 'date': stage.date});
    }

    // CoverLetterQuestion 리스트 로드
    _coverLetterQuestions.clear();
    _coverLetterQuestions.addAll(application.coverLetterQuestions);

    // 알림 설정 로드
    final notificationSettings = application.notificationSettings;
    if (notificationSettings.deadlineNotification) {
      _deadlineNotificationSettings = NotificationSettings(
        deadlineNotification: true,
        deadlineTiming: notificationSettings.deadlineTiming,
        customHoursBefore: notificationSettings.customHoursBefore,
      );
    }
    if (notificationSettings.announcementNotification) {
      _announcementNotificationSettings = NotificationSettings(
        announcementNotification: true,
        announcementTiming: notificationSettings.announcementTiming,
      );
    }
  }

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.application != null ? '공고 수정' : AppStrings.addApplication,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _validateAndSave(context);
            },
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phase 1: 필수 입력 필드
            _buildRequiredFields(context),
            const SizedBox(height: 24),

            // Phase 3: 동적 추가 기능
            _buildDynamicFields(context),
            const SizedBox(height: 24),

            // 기타 메모 입력 (제일 하단)
            _buildMemoField(context),
            // 하단 여백 추가 (키보드가 올라올 때를 대비)
            const SizedBox(height: 100),
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
        LabeledTextField(
          label: AppStrings.companyNameRequired,
          controller: _companyNameController,
          icon: Icons.business,
          hintText: '회사명을 입력하세요',
          errorText: _companyNameError,
          onChanged: () {
            if (_companyNameError != null) {
              setState(() {
                _companyNameError = null;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        // 직무명 입력
        LabeledTextField(
          label: AppStrings.position,
          controller: _positionController,
          icon: Icons.work_outline,
          hintText: '직무명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 지원서 링크 입력
        LinkTextField(
          controller: _applicationLinkController,
          errorText: _applicationLinkError,
          onChanged: () {
            if (_applicationLinkError != null) {
              setState(() {
                _applicationLinkError = null;
              });
            }
          },
          onTestLink: (url) async {
            await _testLink(context);
          },
        ),
        const SizedBox(height: 24),

        // 서류 마감일 선택
        DateTimeField(
          label: AppStrings.deadlineRequired,
          icon: Icons.calendar_today,
          selectedDate: _deadline,
          errorText: _deadlineError,
          notificationSettings: _deadlineNotificationSettings,
          includeTime: _deadlineIncludeTime,
          selectedTime: _deadlineTime,
          onDateSelected: (date) {
            setState(() {
              // 날짜만 선택한 경우, 시간 포함 여부에 따라 시간 설정
              if (_deadlineIncludeTime && _deadlineTime != null) {
                _deadline = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _deadlineTime!.hour,
                  _deadlineTime!.minute,
                );
              } else {
                _deadline = DateTime(date.year, date.month, date.day);
              }
              _deadlineError = null;
            });
          },
          onTimeToggled: (includeTime) {
            setState(() {
              _deadlineIncludeTime = includeTime;
              if (includeTime) {
                _deadlineTime =
                    _deadlineTime ?? const TimeOfDay(hour: 0, minute: 0);
                if (_deadline != null) {
                  _deadline = DateTime(
                    _deadline!.year,
                    _deadline!.month,
                    _deadline!.day,
                    _deadlineTime!.hour,
                    _deadlineTime!.minute,
                  );
                }
              } else {
                _deadlineTime = null;
                if (_deadline != null) {
                  _deadline = DateTime(
                    _deadline!.year,
                    _deadline!.month,
                    _deadline!.day,
                  );
                }
              }
            });
          },
          onTimeSelected: (time) {
            setState(() {
              _deadlineTime = time;
              if (_deadline != null) {
                _deadline = DateTime(
                  _deadline!.year,
                  _deadline!.month,
                  _deadline!.day,
                  time.hour,
                  time.minute,
                );
              }
            });
          },
          onNotificationSettingsChanged: (settings) {
            setState(() {
              _deadlineNotificationSettings = settings;
            });
          },
          notificationType: 'deadline',
          onNotificationSettingsTap: _showNotificationSettingsDialog,
        ),
        const SizedBox(height: 24),

        // 서류 발표일 선택
        DateTimeField(
          label: AppStrings.announcementDate,
          icon: Icons.campaign,
          selectedDate: _announcementDate,
          notificationSettings: _announcementNotificationSettings,
          includeTime: _announcementDateIncludeTime,
          selectedTime: _announcementDateTime,
          onDateSelected: (date) {
            setState(() {
              // 날짜만 선택한 경우, 시간 포함 여부에 따라 시간 설정
              if (_announcementDateIncludeTime &&
                  _announcementDateTime != null) {
                _announcementDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _announcementDateTime!.hour,
                  _announcementDateTime!.minute,
                );
              } else {
                _announcementDate = DateTime(date.year, date.month, date.day);
              }
            });
          },
          onTimeToggled: (includeTime) {
            setState(() {
              _announcementDateIncludeTime = includeTime;
              if (includeTime) {
                _announcementDateTime =
                    _announcementDateTime ??
                    const TimeOfDay(hour: 0, minute: 0);
                if (_announcementDate != null) {
                  _announcementDate = DateTime(
                    _announcementDate!.year,
                    _announcementDate!.month,
                    _announcementDate!.day,
                    _announcementDateTime!.hour,
                    _announcementDateTime!.minute,
                  );
                }
              } else {
                _announcementDateTime = null;
                if (_announcementDate != null) {
                  _announcementDate = DateTime(
                    _announcementDate!.year,
                    _announcementDate!.month,
                    _announcementDate!.day,
                  );
                }
              }
            });
          },
          onTimeSelected: (time) {
            setState(() {
              _announcementDateTime = time;
              if (_announcementDate != null) {
                _announcementDate = DateTime(
                  _announcementDate!.year,
                  _announcementDate!.month,
                  _announcementDate!.day,
                  time.hour,
                  time.minute,
                );
              }
            });
          },
          onNotificationSettingsChanged: (settings) {
            setState(() {
              _announcementNotificationSettings = settings;
            });
          },
          notificationType: 'announcement',
          onNotificationSettingsTap: _showNotificationSettingsDialog,
        ),
      ],
    );
  }

  // Phase 1: 폼 필드 빌더 메서드들은 위젯으로 분리됨
  // - _buildTextField -> LabeledTextField
  // - _buildLinkField -> LinkTextField
  // - _buildDateFieldWithNotification -> DateTimeField

  // 메모 입력 필드 (여러 줄)
  Widget _buildMemoField(BuildContext context) {
    return LabeledTextField(
      label: AppStrings.applicationMemo,
      controller: _memoController,
      icon: Icons.note_outlined,
      hintText: '메모를 입력하세요',
      maxLines: 5,
      subtitle: '공고에 대한 메모',
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
                    formatDate(stage['date'] as DateTime),
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
                              ? formatDate(selectedDate!)
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

  // Phase 2: 일정 수정 다이얼로그 - EditStageDialog 위젯으로 분리됨
  void _showEditStageDialog(BuildContext context, int index) {
    final stage = _nextStages[index];
    showDialog(
      context: context,
      builder: (context) => EditStageDialog(
        initialType: stage['type'] as String,
        initialDate: stage['date'] as DateTime,
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _nextStages[index] = {
            'type': result['type'] as String,
            'date': result['date'] as DateTime,
          };
        });
      }
    });
  }

  // Phase 2: 일정 삭제 확인 다이얼로그 - DeleteStageConfirmDialog 위젯으로 분리됨
  void _showDeleteStageConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => const DeleteStageConfirmDialog(),
    ).then((result) {
      if (result == true) {
        setState(() {
          _nextStages.removeAt(index);
        });
      }
    });
  }

  // 자기소개서 문항 섹션
  Widget _buildCoverLetterQuestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '문항 구조를 관리합니다. 답변은 공고 상세에서 작성합니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showAddQuestionDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_coverLetterQuestions.isEmpty)
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
          )
        else
          ...List.generate(_coverLetterQuestions.length, (index) {
            return _buildQuestionItem(
              context,
              _coverLetterQuestions[index],
              index,
            );
          }),
      ],
    );
  }

  // Phase 2: 문항 아이템 위젯
  Widget _buildQuestionItem(
    BuildContext context,
    CoverLetterQuestion question,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primary,
                  onPressed: () {
                    _showEditQuestionDialog(context, index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.error,
                  onPressed: () {
                    _showDeleteQuestionConfirmDialog(context, index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${AppStrings.maxCharacters}: ${question.maxLength}자',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Phase 2: 문항 추가 다이얼로그 - AddQuestionDialog 위젯으로 분리됨
  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddQuestionDialog(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _coverLetterQuestions.add(
            CoverLetterQuestion(
              question: result['question'] as String,
              maxLength: result['maxLength'] as int,
            ),
          );
        });
      }
    });
  }

  // Phase 2: 문항 수정 다이얼로그 - EditQuestionDialog 위젯으로 분리됨
  void _showEditQuestionDialog(BuildContext context, int index) {
    final question = _coverLetterQuestions[index];
    showDialog(
      context: context,
      builder: (context) => EditQuestionDialog(
        initialQuestion: question.question,
        initialMaxLength: question.maxLength,
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _coverLetterQuestions[index] = CoverLetterQuestion(
            question: result['question'] as String,
            maxLength: result['maxLength'] as int,
            answer: question.answer,
          );
        });
      }
    });
  }

  // Phase 1: 알림 아이콘/색상 메서드는 DateTimeField 위젯으로 이동됨

  // Phase 2: 알림 설정 다이얼로그 - NotificationSettingsDialog 위젯으로 분리됨
  void _showNotificationSettingsDialog(
    BuildContext context,
    String type,
    Function(NotificationSettings?) onSettingsChanged,
  ) {
    // 현재 설정 가져오기
    NotificationSettings? currentSettings;
    if (type == 'deadline') {
      currentSettings = _deadlineNotificationSettings;
    } else if (type == 'announcement') {
      currentSettings = _announcementNotificationSettings;
    }

    showDialog(
      context: context,
      builder: (context) => NotificationSettingsDialog(
        notificationType: type,
        initialSettings: currentSettings,
      ),
    ).then((result) {
      if (result != null) {
        onSettingsChanged(result as NotificationSettings?);
      }
    });
  }

  // Phase 2: 문항 삭제 확인 다이얼로그 - DeleteQuestionConfirmDialog 위젯으로 분리됨
  void _showDeleteQuestionConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteQuestionConfirmDialog(
        questionText: _coverLetterQuestions[index].question,
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _coverLetterQuestions.removeAt(index);
        });
      }
    });
  }

  // Phase 3: URL 형식 검증
  bool _isValidUrl(String url) {
    if (url.trim().isEmpty) {
      return false;
    }

    // http:// 또는 https://로 시작하는지 확인
    final urlPattern = RegExp(r'^https?://.+', caseSensitive: false);

    return urlPattern.hasMatch(url.trim());
  }

  // Phase 3: 필수 필드 유효성 검사
  bool _validateRequiredFields() {
    bool isValid = true;

    // 회사명 검증
    if (_companyNameController.text.trim().isEmpty) {
      _companyNameError = '회사명을 입력해주세요.';
      isValid = false;
    } else {
      _companyNameError = null;
    }

    // 지원서 링크 검증 (선택 항목이지만 입력한 경우 URL 형식 검증)
    final linkText = _applicationLinkController.text.trim();
    if (linkText.isNotEmpty && !_isValidUrl(linkText)) {
      _applicationLinkError = '올바른 URL 형식을 입력해주세요. (예: https://...)';
      isValid = false;
    } else {
      _applicationLinkError = null;
    }

    // 마감일 검증
    if (_deadline == null) {
      _deadlineError = '서류 마감일을 선택해주세요.';
      isValid = false;
    } else {
      _deadlineError = null;
    }

    return isValid;
  }

  // Phase 3: 저장 전 유효성 검사 및 저장
  void _validateAndSave(BuildContext context) {
    // 모든 에러 메시지 초기화
    setState(() {
      _companyNameError = null;
      _applicationLinkError = null;
      _deadlineError = null;
    });

    // 유효성 검사 수행
    if (!_validateRequiredFields()) {
      // 에러가 있으면 첫 번째 에러 필드로 스크롤
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 입력 항목을 확인해주세요.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Phase 5: 유효성 검사 통과 시 저장 로직 실행
    _saveApplication();
  }

  // Phase 5: Application 저장
  Future<void> _saveApplication() async {
    try {
      // NextStage 리스트 변환
      final List<NextStage> nextStages = _nextStages.map((stage) {
        return NextStage(
          type: stage['type'] as String,
          date: stage['date'] as DateTime,
        );
      }).toList();

      // 알림 설정 통합
      NotificationSettings notificationSettings = NotificationSettings();
      if (_deadlineNotificationSettings != null) {
        notificationSettings = notificationSettings.copyWith(
          deadlineNotification:
              _deadlineNotificationSettings!.deadlineNotification,
          deadlineTiming: _deadlineNotificationSettings!.deadlineTiming,
          customHoursBefore: _deadlineNotificationSettings!.customHoursBefore,
        );
      }
      if (_announcementNotificationSettings != null) {
        notificationSettings = notificationSettings.copyWith(
          announcementNotification:
              _announcementNotificationSettings!.announcementNotification,
          announcementTiming:
              _announcementNotificationSettings!.announcementTiming,
        );
      }

      // Phase 7: Application 객체 생성 (수정 모드인 경우 기존 데이터 유지)
      final now = DateTime.now();
      final application = Application(
        id:
            _editingApplicationId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _companyNameController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        applicationLink: _applicationLinkController.text.trim().isEmpty
            ? null
            : _applicationLinkController.text.trim(),
        deadline: _deadline!,
        announcementDate: _announcementDate,
        nextStages: nextStages,
        coverLetterQuestions: _coverLetterQuestions,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        status: widget.application?.status ?? ApplicationStatus.notApplied,
        isApplied: widget.application?.isApplied ?? false,
        notificationSettings: notificationSettings,
        createdAt: widget.application?.createdAt ?? now,
        updatedAt: now, // Phase 7: 수정 시 updatedAt 업데이트
      );

      // StorageService를 사용하여 저장
      final storageService = StorageService();
      final success = await storageService.saveApplication(application);

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingApplicationId != null
                  ? '공고가 성공적으로 수정되었습니다.'
                  : '공고가 성공적으로 저장되었습니다.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // 저장 성공 시 화면 닫기
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

    // URL 열기 - canLaunchUrl 체크 없이 직접 시도
    // LaunchMode.externalApplication을 사용하면 사용자가 브라우저를 선택할 수 있습니다
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 열 수 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
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
