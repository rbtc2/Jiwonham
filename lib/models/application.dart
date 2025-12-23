// Application 모델
// 공고 정보를 담는 데이터 모델

import 'application_status.dart';
import 'next_stage.dart';
import 'cover_letter_question.dart';
import 'notification_settings.dart';
import 'interview_review.dart';
import 'interview_question.dart';
import 'interview_checklist.dart';
import 'interview_schedule.dart';
import 'experience_level.dart';
import 'preparation_checklist.dart';

class Application {
  final String id;
  final String companyName; // 회사명 (필수)
  final String? position; // 직무명
  final ExperienceLevel? experienceLevel; // 구분 (인턴/신입/경력직)
  final String? applicationLink; // 지원서 링크 (선택)
  final String? workplace; // 근무처 (선택)
  final DateTime deadline; // 서류 마감일 (필수)
  final DateTime? announcementDate; // 서류 발표일
  final List<PreparationChecklist> preparationChecklist; // 지원 준비 체크리스트
  final List<NextStage> nextStages; // 다음 전형 일정 리스트
  final List<CoverLetterQuestion> coverLetterQuestions; // 자기소개서 문항 리스트
  final List<InterviewReview> interviewReviews; // 면접 후기 리스트
  final List<InterviewQuestion> interviewQuestions; // 면접 질문 준비 리스트
  final List<InterviewChecklist> interviewChecklist; // 면접 체크리스트 리스트
  final InterviewSchedule? interviewSchedule; // 면접 일정 정보
  final String? memo; // 기타 메모
  final ApplicationStatus status; // 상태
  final bool isApplied; // 지원 완료 체크
  final bool isArchived; // 보관함 여부
  final String? archiveFolderId; // 보관함 폴더 ID (null이면 보관함 루트)
  final NotificationSettings notificationSettings; // 알림 설정
  final DateTime createdAt; // 생성일
  final DateTime updatedAt; // 수정일

  Application({
    required this.id,
    required this.companyName,
    this.position,
    this.experienceLevel,
    this.applicationLink,
    this.workplace,
    required this.deadline,
    this.announcementDate,
    List<PreparationChecklist>? preparationChecklist,
    List<NextStage>? nextStages,
    List<CoverLetterQuestion>? coverLetterQuestions,
    List<InterviewReview>? interviewReviews,
    List<InterviewQuestion>? interviewQuestions,
    List<InterviewChecklist>? interviewChecklist,
    this.interviewSchedule,
    this.memo,
    this.status = ApplicationStatus.notApplied,
    this.isApplied = false,
    this.isArchived = false,
    this.archiveFolderId,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : preparationChecklist = preparationChecklist ?? [],
       nextStages = nextStages ?? [],
       coverLetterQuestions = coverLetterQuestions ?? [],
       interviewReviews = interviewReviews ?? [],
       interviewQuestions = interviewQuestions ?? [],
       interviewChecklist = interviewChecklist ?? [],
       notificationSettings = notificationSettings ?? NotificationSettings(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'position': position,
      'experienceLevel': experienceLevel?.name,
      'applicationLink': applicationLink,
      'workplace': workplace,
      'deadline': deadline.toIso8601String(),
      'announcementDate': announcementDate?.toIso8601String(),
      'preparationChecklist': preparationChecklist
          .map((item) => item.toJson())
          .toList(),
      'nextStages': nextStages.map((stage) => stage.toJson()).toList(),
      'coverLetterQuestions': coverLetterQuestions
          .map((q) => q.toJson())
          .toList(),
      'interviewReviews': interviewReviews.map((r) => r.toJson()).toList(),
      'interviewQuestions': interviewQuestions.map((q) => q.toJson()).toList(),
      'interviewChecklist': interviewChecklist.map((c) => c.toJson()).toList(),
      'interviewSchedule': interviewSchedule?.toJson(),
      'memo': memo,
      'status': status.name,
      'isApplied': isApplied,
      'isArchived': isArchived,
      'archiveFolderId': archiveFolderId,
      'notificationSettings': notificationSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      position: json['position'] as String?,
      experienceLevel: json['experienceLevel'] != null
          ? ExperienceLevel.values.firstWhere(
              (e) => e.name == json['experienceLevel'],
              orElse: () => ExperienceLevel.entry,
            )
          : null,
      applicationLink: json['applicationLink'] as String?,
      workplace: json['workplace'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      announcementDate: json['announcementDate'] != null
          ? DateTime.parse(json['announcementDate'] as String)
          : null,
      preparationChecklist:
          (json['preparationChecklist'] as List<dynamic>?)
              ?.map(
                (e) => PreparationChecklist.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      nextStages:
          (json['nextStages'] as List<dynamic>?)
              ?.map((e) => NextStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      coverLetterQuestions:
          (json['coverLetterQuestions'] as List<dynamic>?)
              ?.map(
                (e) => CoverLetterQuestion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      interviewReviews:
          (json['interviewReviews'] as List<dynamic>?)
              ?.map((e) => InterviewReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      interviewQuestions:
          (json['interviewQuestions'] as List<dynamic>?)
              ?.map(
                (e) => InterviewQuestion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      interviewChecklist:
          (json['interviewChecklist'] as List<dynamic>?)
              ?.map(
                (e) => InterviewChecklist.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      interviewSchedule: json['interviewSchedule'] != null
          ? InterviewSchedule.fromJson(
              json['interviewSchedule'] as Map<String, dynamic>,
            )
          : null,
      memo: json['memo'] as String?,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.notApplied,
      ),
      isApplied: json['isApplied'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      archiveFolderId: json['archiveFolderId'] as String?,
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(
              json['notificationSettings'] as Map<String, dynamic>,
            )
          : NotificationSettings(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // 복사 생성자
  Application copyWith({
    String? id,
    String? companyName,
    String? position,
    ExperienceLevel? experienceLevel,
    String? applicationLink,
    String? workplace,
    DateTime? deadline,
    DateTime? announcementDate,
    List<PreparationChecklist>? preparationChecklist,
    List<NextStage>? nextStages,
    List<CoverLetterQuestion>? coverLetterQuestions,
    List<InterviewReview>? interviewReviews,
    List<InterviewQuestion>? interviewQuestions,
    List<InterviewChecklist>? interviewChecklist,
    InterviewSchedule? interviewSchedule,
    String? memo,
    ApplicationStatus? status,
    bool? isApplied,
    bool? isArchived,
    String? archiveFolderId,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Application(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      applicationLink: applicationLink ?? this.applicationLink,
      workplace: workplace ?? this.workplace,
      deadline: deadline ?? this.deadline,
      announcementDate: announcementDate ?? this.announcementDate,
      preparationChecklist: preparationChecklist ?? this.preparationChecklist,
      nextStages: nextStages ?? this.nextStages,
      coverLetterQuestions: coverLetterQuestions ?? this.coverLetterQuestions,
      interviewReviews: interviewReviews ?? this.interviewReviews,
      interviewQuestions: interviewQuestions ?? this.interviewQuestions,
      interviewChecklist: interviewChecklist ?? this.interviewChecklist,
      interviewSchedule: interviewSchedule ?? this.interviewSchedule,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      isApplied: isApplied ?? this.isApplied,
      isArchived: isArchived ?? this.isArchived,
      archiveFolderId: archiveFolderId ?? this.archiveFolderId,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // D-day 계산
  int get daysUntilDeadline {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDate.difference(today).inDays;
  }

  // 마감일이 지났는지 확인
  bool get isDeadlinePassed => daysUntilDeadline < 0;

  // 마감 임박 여부 (D-7 이내)
  bool get isUrgent => daysUntilDeadline >= 0 && daysUntilDeadline <= 7;
}
