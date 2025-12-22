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
import '../../utils/validation.dart';
// Phase 6: 섹션별 위젯 import
import '../../widgets/application_form_sections/next_stages_section.dart';
import '../../widgets/application_form_sections/cover_letter_questions_section.dart';
// Phase 7: 상태 관리
import '../../models/application_form_data.dart';

class AddEditApplicationScreen extends StatefulWidget {
  final Application? application; // Phase 7: 수정 모드용 기존 Application

  const AddEditApplicationScreen({super.key, this.application});

  @override
  State<AddEditApplicationScreen> createState() =>
      _AddEditApplicationScreenState();
}

class _AddEditApplicationScreenState extends State<AddEditApplicationScreen> {
  // Phase 7: 폼 데이터를 ApplicationFormData로 통합 관리
  late ApplicationFormData _formData;

  @override
  void initState() {
    super.initState();
    // Phase 7: ApplicationFormData 초기화
    _formData = ApplicationFormData();
    // 기존 Application이 있으면 데이터 로드
    if (widget.application != null) {
      _loadApplicationData(widget.application!);
    }
  }

  // Phase 7: 기존 Application 데이터 로드
  void _loadApplicationData(Application application) {
    // 시간 정보 추출
    bool deadlineIncludeTime = false;
    TimeOfDay? deadlineTime;
    if (application.deadline.hour != 0 || application.deadline.minute != 0) {
      deadlineIncludeTime = true;
      deadlineTime = TimeOfDay(
        hour: application.deadline.hour,
        minute: application.deadline.minute,
      );
    }

    bool announcementDateIncludeTime = false;
    TimeOfDay? announcementDateTime;
    if (application.announcementDate != null) {
      final announcementHour = application.announcementDate!.hour;
      final announcementMinute = application.announcementDate!.minute;
      if (announcementHour != 0 || announcementMinute != 0) {
        announcementDateIncludeTime = true;
        announcementDateTime = TimeOfDay(
          hour: announcementHour,
          minute: announcementMinute,
        );
      }
    }

    // NextStage 리스트 변환
    final List<Map<String, dynamic>> nextStages = application.nextStages
        .map((stage) => {'type': stage.type, 'date': stage.date})
        .toList();

    // 알림 설정 추출
    final notificationSettings = application.notificationSettings;
    NotificationSettings? deadlineNotificationSettings;
    if (notificationSettings.deadlineNotification) {
      deadlineNotificationSettings = NotificationSettings(
        deadlineNotification: true,
        deadlineTiming: notificationSettings.deadlineTiming,
        customHoursBefore: notificationSettings.customHoursBefore,
      );
    }
    NotificationSettings? announcementNotificationSettings;
    if (notificationSettings.announcementNotification) {
      announcementNotificationSettings = NotificationSettings(
        announcementNotification: true,
        announcementTiming: notificationSettings.announcementTiming,
      );
    }

    // ApplicationFormData 업데이트
    setState(() {
      _formData = ApplicationFormData(
        companyNameController: TextEditingController(
          text: application.companyName,
        ),
        applicationLinkController: TextEditingController(
          text: application.applicationLink ?? '',
        ),
        positionController: TextEditingController(
          text: application.position ?? '',
        ),
        memoController: TextEditingController(text: application.memo ?? ''),
        deadline: application.deadline,
        announcementDate: application.announcementDate,
        nextStages: nextStages,
        coverLetterQuestions: List.from(application.coverLetterQuestions),
        deadlineIncludeTime: deadlineIncludeTime,
        deadlineTime: deadlineTime,
        announcementDateIncludeTime: announcementDateIncludeTime,
        announcementDateTime: announcementDateTime,
        deadlineNotificationSettings: deadlineNotificationSettings,
        announcementNotificationSettings: announcementNotificationSettings,
        editingApplicationId: application.id,
      );
    });
  }

  @override
  void dispose() {
    // Phase 7: ApplicationFormData의 컨트롤러들 dispose
    _formData.dispose();
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
          controller: _formData.companyNameController,
          icon: Icons.business,
          hintText: '회사명을 입력하세요',
          errorText: _formData.companyNameError,
          onChanged: () {
            if (_formData.companyNameError != null) {
              setState(() {
                _formData = _formData.copyWith(
                  companyNameErrorNull: () => null,
                );
              });
            }
          },
        ),
        const SizedBox(height: 24),

        // 직무명 입력
        LabeledTextField(
          label: AppStrings.position,
          controller: _formData.positionController,
          icon: Icons.work_outline,
          hintText: '직무명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 지원서 링크 입력
        LinkTextField(
          controller: _formData.applicationLinkController,
          errorText: _formData.applicationLinkError,
          onChanged: () {
            if (_formData.applicationLinkError != null) {
              setState(() {
                _formData = _formData.copyWith(
                  applicationLinkErrorNull: () => null,
                );
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
          selectedDate: _formData.deadline,
          errorText: _formData.deadlineError,
          notificationSettings: _formData.deadlineNotificationSettings,
          includeTime: _formData.deadlineIncludeTime,
          selectedTime: _formData.deadlineTime,
          onDateSelected: (date) {
            setState(() {
              // 날짜만 선택한 경우, 시간 포함 여부에 따라 시간 설정
              DateTime? newDeadline;
              if (_formData.deadlineIncludeTime &&
                  _formData.deadlineTime != null) {
                newDeadline = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _formData.deadlineTime!.hour,
                  _formData.deadlineTime!.minute,
                );
              } else {
                newDeadline = DateTime(date.year, date.month, date.day);
              }
              _formData = _formData.copyWith(
                deadline: newDeadline,
                deadlineErrorNull: () => null,
              );
            });
          },
          onTimeToggled: (includeTime) {
            setState(() {
              TimeOfDay? newDeadlineTime = _formData.deadlineTime;
              DateTime? newDeadline = _formData.deadline;

              if (includeTime) {
                newDeadlineTime =
                    newDeadlineTime ?? const TimeOfDay(hour: 0, minute: 0);
                if (newDeadline != null) {
                  newDeadline = DateTime(
                    newDeadline.year,
                    newDeadline.month,
                    newDeadline.day,
                    newDeadlineTime.hour,
                    newDeadlineTime.minute,
                  );
                }
              } else {
                newDeadlineTime = null;
                if (newDeadline != null) {
                  newDeadline = DateTime(
                    newDeadline.year,
                    newDeadline.month,
                    newDeadline.day,
                  );
                }
              }

              _formData = _formData.copyWith(
                deadlineIncludeTime: includeTime,
                deadlineTime: newDeadlineTime,
                deadline: newDeadline,
              );
            });
          },
          onTimeSelected: (time) {
            setState(() {
              DateTime? newDeadline = _formData.deadline;
              if (newDeadline != null) {
                newDeadline = DateTime(
                  newDeadline.year,
                  newDeadline.month,
                  newDeadline.day,
                  time.hour,
                  time.minute,
                );
              }
              _formData = _formData.copyWith(
                deadlineTime: time,
                deadline: newDeadline,
              );
            });
          },
          onNotificationSettingsChanged: (settings) {
            setState(() {
              _formData = _formData.copyWith(
                deadlineNotificationSettings: settings,
              );
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
          selectedDate: _formData.announcementDate,
          notificationSettings: _formData.announcementNotificationSettings,
          includeTime: _formData.announcementDateIncludeTime,
          selectedTime: _formData.announcementDateTime,
          onDateSelected: (date) {
            setState(() {
              // 날짜만 선택한 경우, 시간 포함 여부에 따라 시간 설정
              DateTime? newAnnouncementDate;
              if (_formData.announcementDateIncludeTime &&
                  _formData.announcementDateTime != null) {
                newAnnouncementDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _formData.announcementDateTime!.hour,
                  _formData.announcementDateTime!.minute,
                );
              } else {
                newAnnouncementDate = DateTime(date.year, date.month, date.day);
              }
              _formData = _formData.copyWith(
                announcementDate: newAnnouncementDate,
              );
            });
          },
          onTimeToggled: (includeTime) {
            setState(() {
              TimeOfDay? newAnnouncementDateTime =
                  _formData.announcementDateTime;
              DateTime? newAnnouncementDate = _formData.announcementDate;

              if (includeTime) {
                newAnnouncementDateTime =
                    newAnnouncementDateTime ??
                    const TimeOfDay(hour: 0, minute: 0);
                if (newAnnouncementDate != null) {
                  newAnnouncementDate = DateTime(
                    newAnnouncementDate.year,
                    newAnnouncementDate.month,
                    newAnnouncementDate.day,
                    newAnnouncementDateTime.hour,
                    newAnnouncementDateTime.minute,
                  );
                }
              } else {
                newAnnouncementDateTime = null;
                if (newAnnouncementDate != null) {
                  newAnnouncementDate = DateTime(
                    newAnnouncementDate.year,
                    newAnnouncementDate.month,
                    newAnnouncementDate.day,
                  );
                }
              }

              _formData = _formData.copyWith(
                announcementDateIncludeTime: includeTime,
                announcementDateTime: newAnnouncementDateTime,
                announcementDate: newAnnouncementDate,
              );
            });
          },
          onTimeSelected: (time) {
            setState(() {
              DateTime? newAnnouncementDate = _formData.announcementDate;
              if (newAnnouncementDate != null) {
                newAnnouncementDate = DateTime(
                  newAnnouncementDate.year,
                  newAnnouncementDate.month,
                  newAnnouncementDate.day,
                  time.hour,
                  time.minute,
                );
              }
              _formData = _formData.copyWith(
                announcementDateTime: time,
                announcementDate: newAnnouncementDate,
              );
            });
          },
          onNotificationSettingsChanged: (settings) {
            setState(() {
              _formData = _formData.copyWith(
                announcementNotificationSettings: settings,
              );
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
      controller: _formData.memoController,
      icon: Icons.note_outlined,
      hintText: '메모를 입력하세요',
      maxLines: 5,
      subtitle: '공고에 대한 메모',
    );
  }

  // Phase 6: 동적 추가 기능 섹션 - 섹션 위젯으로 분리됨
  Widget _buildDynamicFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NextStagesSection(
          stages: _formData.nextStages,
          onAddStage: () => _showAddStageDialog(context),
          onEditStage: (index) => _showEditStageDialog(context, index),
          onDeleteStage: (index) =>
              _showDeleteStageConfirmDialog(context, index),
        ),
        const SizedBox(height: 24),
        CoverLetterQuestionsSection(
          questions: _formData.coverLetterQuestions,
          onAddQuestion: () => _showAddQuestionDialog(context),
          onEditQuestion: (index) => _showEditQuestionDialog(context, index),
          onDeleteQuestion: (index) =>
              _showDeleteQuestionConfirmDialog(context, index),
        ),
      ],
    );
  }

  // Phase 2: 일정 추가 다이얼로그 - AddStageDialog 위젯으로 분리됨
  void _showAddStageDialog(BuildContext context) {
    AddStageDialog.show(context).then((result) {
      if (result != null) {
        setState(() {
          final updatedStages = List<Map<String, dynamic>>.from(
            _formData.nextStages,
          );
          updatedStages.add({
            'type': result['type'] as String,
            'date': result['date'] as DateTime,
          });
          _formData = _formData.copyWith(nextStages: updatedStages);
        });
      }
    });
  }

  // Phase 2: 일정 수정 다이얼로그 - EditStageDialog 위젯으로 분리됨
  void _showEditStageDialog(BuildContext context, int index) {
    final stage = _formData.nextStages[index];
    EditStageDialog.show(
      context,
      initialType: stage['type'] as String,
      initialDate: stage['date'] as DateTime,
    ).then((result) {
      if (result != null) {
        setState(() {
          final updatedStages = List<Map<String, dynamic>>.from(
            _formData.nextStages,
          );
          updatedStages[index] = {
            'type': result['type'] as String,
            'date': result['date'] as DateTime,
          };
          _formData = _formData.copyWith(nextStages: updatedStages);
        });
      }
    });
  }

  // Phase 2: 일정 삭제 확인 다이얼로그 - DeleteStageConfirmDialog 위젯으로 분리됨
  void _showDeleteStageConfirmDialog(BuildContext context, int index) {
    DeleteStageConfirmDialog.show(context).then((result) {
      if (result == true) {
        setState(() {
          final updatedStages = List<Map<String, dynamic>>.from(
            _formData.nextStages,
          );
          updatedStages.removeAt(index);
          _formData = _formData.copyWith(nextStages: updatedStages);
        });
      }
    });
  }

  // Phase 6: 자기소개서 문항 섹션 - CoverLetterQuestionsSection 위젯으로 분리됨

  // Phase 2: 문항 추가 다이얼로그 - AddQuestionDialog 위젯으로 분리됨
  void _showAddQuestionDialog(BuildContext context) {
    AddQuestionDialog.show(context).then((result) {
      if (result != null) {
        setState(() {
          final updatedQuestions = List<CoverLetterQuestion>.from(
            _formData.coverLetterQuestions,
          );
          updatedQuestions.add(
            CoverLetterQuestion(
              question: result['question'] as String,
              maxLength: result['maxLength'] as int,
            ),
          );
          _formData = _formData.copyWith(
            coverLetterQuestions: updatedQuestions,
          );
        });
      }
    });
  }

  // Phase 2: 문항 수정 다이얼로그 - EditQuestionDialog 위젯으로 분리됨
  void _showEditQuestionDialog(BuildContext context, int index) {
    final question = _formData.coverLetterQuestions[index];
    EditQuestionDialog.show(
      context,
      initialQuestion: question.question,
      initialMaxLength: question.maxLength,
    ).then((result) {
      if (result != null) {
        setState(() {
          final updatedQuestions = List<CoverLetterQuestion>.from(
            _formData.coverLetterQuestions,
          );
          updatedQuestions[index] = CoverLetterQuestion(
            question: result['question'] as String,
            maxLength: result['maxLength'] as int,
            answer: question.answer,
          );
          _formData = _formData.copyWith(
            coverLetterQuestions: updatedQuestions,
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
      currentSettings = _formData.deadlineNotificationSettings;
    } else if (type == 'announcement') {
      currentSettings = _formData.announcementNotificationSettings;
    }

    NotificationSettingsDialog.show(
      context,
      notificationType: type,
      initialSettings: currentSettings,
    ).then((result) {
      if (result != null) {
        onSettingsChanged(result);
      }
    });
  }

  // Phase 2: 문항 삭제 확인 다이얼로그 - DeleteQuestionConfirmDialog 위젯으로 분리됨
  void _showDeleteQuestionConfirmDialog(BuildContext context, int index) {
    DeleteQuestionConfirmDialog.show(
      context,
      questionText: _formData.coverLetterQuestions[index].question,
    ).then((result) {
      if (result == true) {
        setState(() {
          final updatedQuestions = List<CoverLetterQuestion>.from(
            _formData.coverLetterQuestions,
          );
          updatedQuestions.removeAt(index);
          _formData = _formData.copyWith(
            coverLetterQuestions: updatedQuestions,
          );
        });
      }
    });
  }

  // Phase 3: 필수 필드 유효성 검사 - validation.dart로 분리됨
  bool _validateRequiredFields() {
    final result = ApplicationFormValidator.validateRequiredFields(
      companyName: _formData.companyNameController.text.trim(),
      applicationLink: _formData.applicationLinkController.text.trim(),
      deadline: _formData.deadline,
    );

    setState(() {
      _formData = _formData.copyWith(
        companyNameError: result.companyNameError,
        applicationLinkError: result.applicationLinkError,
        deadlineError: result.deadlineError,
      );
    });

    return result.isValid;
  }

  // Phase 3: 저장 전 유효성 검사 및 저장
  void _validateAndSave(BuildContext context) {
    // 모든 에러 메시지 초기화
    setState(() {
      _formData = _formData.copyWith(
        companyNameErrorNull: () => null,
        applicationLinkErrorNull: () => null,
        deadlineErrorNull: () => null,
      );
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
      final List<NextStage> nextStages = _formData.nextStages.map((stage) {
        return NextStage(
          type: stage['type'] as String,
          date: stage['date'] as DateTime,
        );
      }).toList();

      // 알림 설정 통합
      NotificationSettings notificationSettings = NotificationSettings();
      if (_formData.deadlineNotificationSettings != null) {
        notificationSettings = notificationSettings.copyWith(
          deadlineNotification:
              _formData.deadlineNotificationSettings!.deadlineNotification,
          deadlineTiming:
              _formData.deadlineNotificationSettings!.deadlineTiming,
          customHoursBefore:
              _formData.deadlineNotificationSettings!.customHoursBefore,
        );
      }
      if (_formData.announcementNotificationSettings != null) {
        notificationSettings = notificationSettings.copyWith(
          announcementNotification: _formData
              .announcementNotificationSettings!
              .announcementNotification,
          announcementTiming:
              _formData.announcementNotificationSettings!.announcementTiming,
        );
      }

      // Phase 7: Application 객체 생성 (수정 모드인 경우 기존 데이터 유지)
      final now = DateTime.now();
      final application = Application(
        id:
            _formData.editingApplicationId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _formData.companyNameController.text.trim(),
        position: _formData.positionController.text.trim().isEmpty
            ? null
            : _formData.positionController.text.trim(),
        applicationLink: _formData.applicationLinkController.text.trim().isEmpty
            ? null
            : _formData.applicationLinkController.text.trim(),
        deadline: _formData.deadline!,
        announcementDate: _formData.announcementDate,
        nextStages: nextStages,
        coverLetterQuestions: _formData.coverLetterQuestions,
        memo: _formData.memoController.text.trim().isEmpty
            ? null
            : _formData.memoController.text.trim(),
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
              _formData.editingApplicationId != null
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
    final urlString = _formData.applicationLinkController.text.trim();

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
