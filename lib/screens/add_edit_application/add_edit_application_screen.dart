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
        _buildTextField(
          context,
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
        _buildTextField(
          context,
          label: AppStrings.position,
          controller: _positionController,
          icon: Icons.work_outline,
          hintText: '직무명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 지원서 링크 입력
        _buildLinkField(context),
        if (_applicationLinkError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _applicationLinkError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),

        // 서류 마감일 선택
        _buildDateFieldWithNotification(
          context,
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
        ),
        const SizedBox(height: 24),

        // 서류 발표일 선택
        _buildDateFieldWithNotification(
          context,
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
    String? errorText,
    VoidCallback? onChanged,
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
            errorText: errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          onChanged: (_) {
            onChanged?.call();
          },
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
              AppStrings.applicationLink,
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
                  errorText: _applicationLinkError,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) {
                  if (_applicationLinkError != null) {
                    setState(() {
                      _applicationLinkError = null;
                    });
                  }
                },
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

  // 날짜 선택 필드 (알림 설정 포함)
  Widget _buildDateFieldWithNotification(
    BuildContext context, {
    required String label,
    required IconData icon,
    DateTime? selectedDate,
    String? errorText,
    NotificationSettings? notificationSettings,
    required Function(DateTime) onDateSelected,
    required Function(NotificationSettings?) onNotificationSettingsChanged,
    required String notificationType,
    bool includeTime = false,
    TimeOfDay? selectedTime,
    Function(bool)? onTimeToggled,
    Function(TimeOfDay)? onTimeSelected,
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
        // 날짜 선택 필드와 시간 포함 토글
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
                    border: Border.all(
                      color: errorText != null
                          ? AppColors.error
                          : Colors.grey.shade300,
                      width: errorText != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? includeTime && selectedTime != null
                                  ? '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')} ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                                  : '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}'
                            : AppStrings.selectDate,
                        style: TextStyle(
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: errorText != null
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 시간 포함 토글
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '시간',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: includeTime,
                  onChanged: onTimeToggled ?? (value) {},
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _showNotificationSettingsDialog(
                  context,
                  notificationType,
                  onNotificationSettingsChanged,
                );
              },
              icon: Icon(
                _getNotificationIcon(notificationType, notificationSettings),
                color: _getNotificationColor(
                  notificationType,
                  notificationSettings,
                ),
              ),
              tooltip: '알림 설정',
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              errorText,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        // 시간 선택 필드 (토글이 켜져 있을 때만 표시)
        if (includeTime) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime:
                    selectedTime ?? const TimeOfDay(hour: 0, minute: 0),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null && onTimeSelected != null) {
                onTimeSelected(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime != null
                            ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                            : '00:00',
                        style: TextStyle(
                          color: selectedTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
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

  // Phase 2: 문항 추가 다이얼로그
  void _showAddQuestionDialog(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController maxLengthController = TextEditingController(
      text: '500',
    );
    bool isValid = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(AppStrings.addQuestion),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.question,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    hintText: '예: 지원 동기를 작성해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        !isValid && questionController.text.trim().isEmpty
                        ? '문항을 입력해주세요.'
                        : null,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    setDialogState(() {
                      isValid = questionController.text.trim().isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppStrings.maxCharacters} (${AppStrings.characterCount})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: maxLengthController,
                  decoration: InputDecoration(
                    hintText: '500',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        !isValid && maxLengthController.text.trim().isEmpty
                        ? '최대 글자 수를 입력해주세요.'
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setDialogState(() {
                      isValid = maxLengthController.text.trim().isNotEmpty;
                    });
                  },
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
                final questionText = questionController.text.trim();
                final maxLengthText = maxLengthController.text.trim();

                if (questionText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('문항을 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (maxLengthText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('최대 글자 수를 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final maxLength = int.tryParse(maxLengthText);
                if (maxLength == null || maxLength <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('올바른 최대 글자 수를 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setState(() {
                  _coverLetterQuestions.add(
                    CoverLetterQuestion(
                      question: questionText,
                      maxLength: maxLength,
                    ),
                  );
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

  // Phase 2: 문항 수정 다이얼로그
  void _showEditQuestionDialog(BuildContext context, int index) {
    final question = _coverLetterQuestions[index];
    final TextEditingController questionController = TextEditingController(
      text: question.question,
    );
    final TextEditingController maxLengthController = TextEditingController(
      text: question.maxLength.toString(),
    );
    bool isValid = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('문항 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.question,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    hintText: '예: 지원 동기를 작성해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        !isValid && questionController.text.trim().isEmpty
                        ? '문항을 입력해주세요.'
                        : null,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    setDialogState(() {
                      isValid = questionController.text.trim().isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppStrings.maxCharacters} (${AppStrings.characterCount})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: maxLengthController,
                  decoration: InputDecoration(
                    hintText: '500',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        !isValid && maxLengthController.text.trim().isEmpty
                        ? '최대 글자 수를 입력해주세요.'
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setDialogState(() {
                      isValid = maxLengthController.text.trim().isNotEmpty;
                    });
                  },
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
                final questionText = questionController.text.trim();
                final maxLengthText = maxLengthController.text.trim();

                if (questionText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('문항을 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (maxLengthText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('최대 글자 수를 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final maxLength = int.tryParse(maxLengthText);
                if (maxLength == null || maxLength <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('올바른 최대 글자 수를 입력해주세요.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setState(() {
                  _coverLetterQuestions[index] = CoverLetterQuestion(
                    question: questionText,
                    maxLength: maxLength,
                    answer: question.answer,
                  );
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

  // Phase 4: 알림 아이콘 가져오기
  IconData _getNotificationIcon(String type, NotificationSettings? settings) {
    bool isEnabled = false;
    if (type == 'deadline') {
      isEnabled = settings?.deadlineNotification ?? false;
    } else if (type == 'announcement') {
      isEnabled = settings?.announcementNotification ?? false;
    }
    return isEnabled ? Icons.notifications : Icons.notifications_outlined;
  }

  // Phase 4: 알림 색상 가져오기
  Color _getNotificationColor(String type, NotificationSettings? settings) {
    bool isEnabled = false;
    if (type == 'deadline') {
      isEnabled = settings?.deadlineNotification ?? false;
    } else if (type == 'announcement') {
      isEnabled = settings?.announcementNotification ?? false;
    }
    return isEnabled ? AppColors.primary : AppColors.textSecondary;
  }

  // Phase 4: 알림 설정 다이얼로그
  void _showNotificationSettingsDialog(
    BuildContext context,
    String type,
    Function(NotificationSettings?) onSettingsChanged,
  ) {
    // 현재 설정 가져오기 또는 기본값
    NotificationSettings? currentSettings;
    if (type == 'deadline') {
      currentSettings = _deadlineNotificationSettings;
    } else if (type == 'announcement') {
      currentSettings = _announcementNotificationSettings;
    }

    bool notificationEnabled = false;
    NotificationTiming? selectedTiming;
    int? customHours = 24;

    if (type == 'deadline') {
      notificationEnabled = currentSettings?.deadlineNotification ?? false;
      selectedTiming =
          currentSettings?.deadlineTiming ?? NotificationTiming.daysBefore3;
      customHours = currentSettings?.customHoursBefore ?? 24;
    } else if (type == 'announcement') {
      notificationEnabled = currentSettings?.announcementNotification ?? false;
      selectedTiming =
          currentSettings?.announcementTiming ?? NotificationTiming.onTheDay;
      customHours = currentSettings?.customHoursBefore ?? 24;
    }

    final TextEditingController customHoursController = TextEditingController(
      text: customHours.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(AppStrings.notificationSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 알림 활성화 스위치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.receiveNotification,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: notificationEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          notificationEnabled = value;
                          if (!value) {
                            selectedTiming = null;
                          } else {
                            selectedTiming =
                                selectedTiming ?? NotificationTiming.onTheDay;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (notificationEnabled) ...[
                  const Text(
                    AppStrings.notificationTiming,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 알림 시점 선택
                  RadioGroup<NotificationTiming>(
                    groupValue: selectedTiming,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTiming = value;
                      });
                    },
                    child: Column(
                      children: [
                        ...NotificationTiming.values.map((timing) {
                          String label = _getNotificationTimingLabel(timing);
                          return RadioListTile<NotificationTiming>(
                            title: Text(label),
                            value: timing,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                      ],
                    ),
                  ),
                  // 사용자 지정 시간 입력
                  if (selectedTiming == NotificationTiming.custom) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customHoursController,
                      decoration: InputDecoration(
                        labelText: '알림 시간 (시간 전)',
                        hintText: '24',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final hours = int.tryParse(value);
                        if (hours != null && hours > 0) {
                          setDialogState(() {
                            customHours = hours;
                          });
                        }
                      },
                    ),
                  ],
                ],
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
                final hours = selectedTiming == NotificationTiming.custom
                    ? int.tryParse(customHoursController.text.trim()) ?? 24
                    : null;

                NotificationSettings? newSettings;
                if (notificationEnabled) {
                  if (type == 'deadline') {
                    newSettings = NotificationSettings(
                      deadlineNotification: true,
                      deadlineTiming: selectedTiming,
                      customHoursBefore:
                          selectedTiming == NotificationTiming.custom
                          ? hours
                          : null,
                    );
                  } else if (type == 'announcement') {
                    newSettings = NotificationSettings(
                      announcementNotification: true,
                      announcementTiming: selectedTiming,
                      customHoursBefore:
                          selectedTiming == NotificationTiming.custom
                          ? hours
                          : null,
                    );
                  }
                } else {
                  newSettings = null;
                }

                onSettingsChanged(newSettings);
                customHoursController.dispose();
                Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  // Phase 4: 알림 시점 라벨 가져오기
  String _getNotificationTimingLabel(NotificationTiming timing) {
    switch (timing) {
      case NotificationTiming.daysBefore7:
        return 'D-7 (7일 전)';
      case NotificationTiming.daysBefore3:
        return 'D-3 (3일 전)';
      case NotificationTiming.daysBefore1:
        return 'D-1 (1일 전)';
      case NotificationTiming.onTheDay:
        return '당일';
      case NotificationTiming.custom:
        return '사용자 지정';
    }
  }

  // Phase 2: 문항 삭제 확인 다이얼로그
  void _showDeleteQuestionConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문항 삭제'),
        content: Text(
          '정말로 이 문항을 삭제하시겠습니까?\n\n"${_coverLetterQuestions[index].question}"',
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
              setState(() {
                _coverLetterQuestions.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
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
