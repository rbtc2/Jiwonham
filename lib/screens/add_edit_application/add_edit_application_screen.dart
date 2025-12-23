// 공고 추가/수정 화면
// 새 공고를 추가하거나 기존 공고를 수정하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_settings.dart';
import '../../models/application.dart';
import '../../models/preparation_checklist.dart';
import '../../services/storage_service.dart';
import '../../services/application_form_converter.dart';
import '../../services/link_test_service.dart';
// Phase 1: 폼 필드 위젯 import (메모 필드용)
import '../../widgets/form_fields/labeled_text_field.dart';
// Phase 2: 다이얼로그 위젯 import
import '../../widgets/dialogs/add_stage_dialog.dart';
import '../../widgets/dialogs/edit_stage_dialog.dart';
import '../../widgets/dialogs/delete_stage_confirm_dialog.dart';
import '../../widgets/dialogs/add_checklist_item_dialog.dart';
import '../../widgets/dialogs/edit_checklist_item_dialog.dart';
import '../../widgets/dialogs/delete_checklist_item_confirm_dialog.dart';
import '../../widgets/dialogs/add_question_dialog.dart';
import '../../widgets/dialogs/edit_question_dialog.dart';
import '../../widgets/dialogs/delete_question_confirm_dialog.dart';
import '../../widgets/dialogs/notification_settings_dialog.dart';
import '../../utils/validation.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/form_data_updater.dart';
// Phase 6: 섹션별 위젯 import
import '../../widgets/application_form_sections/preparation_checklist_section.dart';
import '../../widgets/application_form_sections/next_stages_section.dart';
import '../../widgets/application_form_sections/cover_letter_questions_section.dart';
// Phase 1: 필수 필드 섹션 위젯 import
import '../../widgets/application_form_sections/required_fields_section.dart';
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

  // Phase 9: 기존 Application 데이터 로드 - ApplicationFormConverter 사용
  void _loadApplicationData(Application application) {
    setState(() {
      _formData = ApplicationFormConverter.fromApplication(application);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.application != null
                    ? Icons.edit_outlined
                    : Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.application != null ? '공고 수정' : AppStrings.addApplication,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _validateAndSave(context);
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text(
                AppStrings.save,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phase 1: 필수 입력 필드
            RequiredFieldsSection(
              formData: _formData,
              onFormDataChanged: (newFormData) {
                setState(() {
                  _formData = newFormData;
                });
              },
              onNotificationSettingsTap: _showNotificationSettingsDialog,
              onTestLink: (url) =>
                  LinkTestService.testAndOpenLink(context, url),
            ),
            const SizedBox(height: 32),

            // Phase 3: 동적 추가 기능
            _buildDynamicFields(context),
            const SizedBox(height: 32),

            // 기타 메모 입력 (제일 하단)
            _buildMemoField(context),
            // 하단 여백 추가 (키보드가 올라올 때를 대비)
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Phase 1: 필수 입력 필드 섹션은 RequiredFieldsSection 위젯으로 분리됨

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
        PreparationChecklistSection(
          checklist: _formData.preparationChecklist,
          onAddItem: () => _showAddChecklistItemDialog(context),
          onEditItem: (index) => _showEditChecklistItemDialog(context, index),
          onDeleteItem: (index) =>
              _showDeleteChecklistItemConfirmDialog(context, index),
          onToggleCheck: (index) {
            setState(() {
              final updatedChecklist = List<PreparationChecklist>.from(
                _formData.preparationChecklist,
              );
              updatedChecklist[index] = updatedChecklist[index].copyWith(
                isChecked: !updatedChecklist[index].isChecked,
              );
              _formData = _formData.copyWith(
                preparationChecklist: updatedChecklist,
              );
            });
          },
        ),
        const SizedBox(height: 24),
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

  // Phase 12: 체크리스트 항목 추가 다이얼로그 - FormDataUpdater 사용
  void _showAddChecklistItemDialog(BuildContext context) {
    AddChecklistItemDialog.show(context).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.addChecklistItem(_formData, result);
        });
      }
    });
  }

  // Phase 12: 체크리스트 항목 수정 다이얼로그 - FormDataUpdater 사용
  void _showEditChecklistItemDialog(BuildContext context, int index) {
    final item = _formData.preparationChecklist[index];
    EditChecklistItemDialog.show(context, item.item).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.updateChecklistItem(
            _formData,
            index,
            result,
          );
        });
      }
    });
  }

  // Phase 12: 체크리스트 항목 삭제 확인 다이얼로그 - FormDataUpdater 사용
  void _showDeleteChecklistItemConfirmDialog(BuildContext context, int index) {
    final item = _formData.preparationChecklist[index];
    DeleteChecklistItemConfirmDialog.show(context, item.item).then((result) {
      if (result == true) {
        setState(() {
          _formData = FormDataUpdater.removeChecklistItem(_formData, index);
        });
      }
    });
  }

  // Phase 12: 일정 추가 다이얼로그 - FormDataUpdater 사용
  void _showAddStageDialog(BuildContext context) {
    AddStageDialog.show(context).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.addStage(
            _formData,
            result['type'] as String,
            result['date'] as DateTime,
          );
        });
      }
    });
  }

  // Phase 12: 일정 수정 다이얼로그 - FormDataUpdater 사용
  void _showEditStageDialog(BuildContext context, int index) {
    final stage = _formData.nextStages[index];
    EditStageDialog.show(
      context,
      initialType: stage['type'] as String,
      initialDate: stage['date'] as DateTime,
    ).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.updateStage(
            _formData,
            index,
            result['type'] as String,
            result['date'] as DateTime,
          );
        });
      }
    });
  }

  // Phase 12: 일정 삭제 확인 다이얼로그 - FormDataUpdater 사용
  void _showDeleteStageConfirmDialog(BuildContext context, int index) {
    DeleteStageConfirmDialog.show(context).then((result) {
      if (result == true) {
        setState(() {
          _formData = FormDataUpdater.removeStage(_formData, index);
        });
      }
    });
  }

  // Phase 6: 자기소개서 문항 섹션 - CoverLetterQuestionsSection 위젯으로 분리됨

  // Phase 12: 문항 추가 다이얼로그 - FormDataUpdater 사용
  void _showAddQuestionDialog(BuildContext context) {
    AddQuestionDialog.show(context).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.addQuestion(
            _formData,
            result['question'] as String,
            result['maxLength'] as int,
          );
        });
      }
    });
  }

  // Phase 12: 문항 수정 다이얼로그 - FormDataUpdater 사용
  void _showEditQuestionDialog(BuildContext context, int index) {
    final question = _formData.coverLetterQuestions[index];
    EditQuestionDialog.show(
      context,
      initialQuestion: question.question,
      initialMaxLength: question.maxLength,
    ).then((result) {
      if (result != null) {
        setState(() {
          _formData = FormDataUpdater.updateQuestion(
            _formData,
            index,
            result['question'] as String,
            result['maxLength'] as int,
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

  // Phase 12: 문항 삭제 확인 다이얼로그 - FormDataUpdater 사용
  void _showDeleteQuestionConfirmDialog(BuildContext context, int index) {
    DeleteQuestionConfirmDialog.show(
      context,
      questionText: _formData.coverLetterQuestions[index].question,
    ).then((result) {
      if (result == true) {
        setState(() {
          _formData = FormDataUpdater.removeQuestion(_formData, index);
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
      SnackBarUtils.showError(context, '필수 입력 항목을 확인해주세요.');
      return;
    }

    // Phase 5: 유효성 검사 통과 시 저장 로직 실행
    _saveApplication();
  }

  // Phase 9: Application 저장 - ApplicationFormConverter 사용
  Future<void> _saveApplication() async {
    try {
      // ApplicationFormConverter를 사용하여 Application 객체 생성
      final application = ApplicationFormConverter.toApplication(
        _formData,
        existingApplication: widget.application,
      );

      // StorageService를 사용하여 저장
      final storageService = StorageService();
      final success = await storageService.saveApplication(application);

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        SnackBarUtils.showSuccess(
          context,
          _formData.editingApplicationId != null
              ? '공고가 성공적으로 수정되었습니다.'
              : '공고가 성공적으로 저장되었습니다.',
        );
        if (!mounted) return;
        Navigator.pop(context, true); // 저장 성공 시 화면 닫기
      } else {
        if (!mounted) return;
        SnackBarUtils.showError(context, '저장 중 오류가 발생했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, '저장 중 오류가 발생했습니다: $e');
    }
  }

  // Phase 11: 링크 테스트 기능은 LinkTestService로 분리됨
}
