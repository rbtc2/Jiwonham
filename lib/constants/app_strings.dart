// 앱 문자열 상수
// - 화면 제목, 버튼 텍스트 등 문자열 정의

class AppStrings {
  // App
  static const String appName = '지원함';

  // Home Screen
  static const String homeTitle = '취업 준비 관리';
  static const String todayStatistics = '나의 통계';
  static const String urgentApplications = '마감 임박 공고';
  static const String urgentApplicationsSubtitle = 'D-3 이내';
  static const String todaySchedule = '오늘의 일정';
  static const String addNewApplication = '새 공고 추가';
  static const String viewAll = '더보기';
  static const String apply = '지원하기';
  static const String viewDetail = '상세보기';

  // Statistics
  static const String totalApplications = '지원';
  static const String inProgress = '진행중';
  static const String passed = '합격';

  // Notification
  static const String notificationSettings = '알림 설정';

  // Add/Edit Application Screen
  static const String addApplication = '새 공고 추가';
  static const String editApplication = '공고 수정';
  static const String save = '저장';
  static const String companyName = '회사명';
  static const String companyNameRequired = '회사명 *';
  static const String position = '직무명';
  static const String applicationLink = '지원서 링크';
  static const String applicationLinkRequired = '지원서 링크 *';
  static const String workplace = '근무지';
  static const String testLink = '링크 테스트';
  static const String deadline = '서류 마감일';
  static const String deadlineRequired = '서류 마감일 *';
  static const String selectDate = '날짜 선택';
  static const String announcementDate = '서류 발표일';
  static const String nextStage = '다음 전형 일정';
  static const String addStage = '일정 추가';
  static const String stageType = '전형 유형';
  static const String stageDate = '일정';
  static const String stageTypeExample = '예: 면접, 최종 면접, 서류 제출';
  static const String editStage = '수정';
  static const String deleteStage = '삭제';
  static const String coverLetterQuestions = '자기소개서 문항';
  static const String coverLetterAnswers = '자기소개서 답변';
  static const String addQuestion = '문항 추가';
  static const String editAnswer = '답변 수정';
  static const String writeAnswer = '답변 작성';
  static const String noCoverLetterQuestions = '자기소개서 문항이 없습니다';
  static const String editQuestionToAdd = '문항을 추가하려면 수정 화면에서 문항을 추가하세요';
  static const String memo = '기타 메모';
  static const String progressMemo = '메모';
  static const String applicationMemo = '메모';
  static const String editProgressMemo = '메모 편집';
  static const String requiredField = '*';

  // Navigation
  static const String navHome = '홈';
  static const String navApplications = '공고';
  static const String navCalendar = '캘린더';

  // Applications Screen
  static const String applicationsTitle = '공고 목록';
  static const String search = '검색';
  static const String filter = '필터';
  static const String all = '전체';
  static const String notApplied = '지원전';
  static const String rejected = '불합격';
  static const String sortBy = '정렬';

  // Calendar Screen
  static const String calendarTitle = '캘린더';
  static const String today = '오늘';
  static const String monthly = '월간';
  static const String weekly = '주간';
  static const String daily = '일간';

  // Search & Filter
  static const String searchPlaceholder = '회사명, 직무명 검색...';
  static const String applyFilter = '필터 적용';
  static const String resetFilter = '초기화';
  static const String sortByDeadline = '마감일순';
  static const String sortByDate = '등록일순';
  static const String sortByCompany = '회사명순';
  static const String deadlineWithin7Days = 'D-7 이내';
  static const String deadlineWithin3Days = 'D-3 이내';
  static const String deadlinePassed = '마감됨';

  // Application Detail Screen
  static const String applicationDetail = '공고 상세';
  static const String edit = '수정';
  static const String delete = '삭제';
  static const String deleteConfirm = '정말 삭제하시겠습니까?';
  static const String deleteConfirmMessage = '이 작업은 되돌릴 수 없습니다.';
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String write = '작성하기';
  static const String editMemo = '메모 편집';
  static const String interviewReview = '면접 후기';
  static const String writeInterviewReview = '면접 후기 작성';
  static const String noInterviewReview = '면접 후기가 없습니다. 면접 후기를 작성해보세요.';
  static const String noMemo = '메모가 없습니다.';
  static const String changeStatus = '상태 변경';
  static const String notAppliedStatus = '지원 전';
  static const String appliedStatus = '지원 완료';
  static const String inProgressStatus = '진행중';
  static const String passedStatus = '합격';
  static const String rejectedStatus = '불합격';
  static const String openLink = '지원서 링크 열기';
  static const String question = '문항';
  static const String answer = '답변';
  static const String characterCount = '글자 수';
  static const String maxCharacters = '최대';
  static const String interviewDate = '면접 일시';
  static const String interviewType = '면접 유형';
  static const String interviewQuestions = '면접 질문';
  static const String interviewReviewText = '면접 후기';
  static const String rating = '평가';
  static const String addInterviewQuestion = '질문 추가';

  // Interview Preparation
  static const String interviewPreparation = '면접 준비';
  static const String interviewQuestionsPrep = '면접 질문 준비';
  static const String interviewExpectedQuestions = '면접 예상 질문';
  static const String addInterviewPrepQuestion = '질문 추가';
  static const String editInterviewPrepQuestion = '질문 수정';
  static const String deleteInterviewPrepQuestion = '질문 삭제';
  static const String writeInterviewAnswer = '답변 작성';
  static const String editInterviewAnswer = '답변 수정';
  static const String noInterviewQuestions = '면접 질문이 없습니다. 질문을 추가해보세요.';
  static const String interviewExpectedQuestionsDesc = '면접 전 준비하는 예상 질문과 답변';
  static const String interviewChecklist = '체크리스트';
  static const String addChecklistItem = '항목 추가';
  static const String editChecklistItem = '항목 수정';
  static const String deleteChecklistItem = '항목 삭제';
  static const String noChecklistItems = '체크리스트 항목이 없습니다. 항목을 추가해보세요.';
  static const String interviewSchedule = '면접 일정';
  static const String interviewLocation = '면접 장소';
  static const String noInterviewSchedule = '면접 일정이 설정되지 않았습니다.';

  // Calendar Screen
  static const String noSchedule = '일정이 없습니다';
  static const String deadlineEvent = '마감일';
  static const String announcementEvent = '발표일';
  static const String interviewEvent = '면접';
  static const String legend = '범례';

  // Notification Settings Screen
  static const String enableNotifications = '알림 활성화';
  static const String deadlineNotification = '마감일 알림';
  static const String announcementNotification = '발표일 알림';
  static const String interviewNotification = '면접 알림';
  static const String notificationTime = '알림 시간';
  static const String defaultNotificationTime = '기본 알림 시간';
  static const String receiveNotification = '알림 받기';
  static const String notificationTiming = '알림 시점';
  static const String daysBefore7 = 'D-7';
  static const String daysBefore3 = 'D-3';
  static const String daysBefore1 = 'D-1';
  static const String onTheDay = '당일';
  static const String customTime = '사용자 지정';
  static const String timeBefore = '시간 전';
  static const String selectTime = '시간 선택';

  // Settings Screen
  static const String settings = '설정';
  static const String notificationDescription = '알림을 끄면 모든 알림이 비활성화됩니다.';
  static const String excludeArchivedFromStats = '보관함 통계 제외';
  static const String excludeArchivedFromStatsDescription = '켜면 보관함에 있는 공고는 통계에서 제외됩니다.';
  static const String premium = '프리미엄';
  static const String removeAds = '광고 제거';
  static const String purchasePremium = '구매하기';
  static const String alreadyPurchased = '이미 구매됨';
  static const String premiumDescription = '광고 없는 깔끔한 환경을 경험하세요.';
  static const String donation = '후원하기';
  static const String buyDeveloperCoffee = '개발자에게 커피 사주기';
  static const String donationDescription = '개발에 힘이 됩니다!';
  static const String dataManagement = '데이터 관리';
  static const String exportData = '데이터 내보내기';
  static const String deleteAllData = '모든 데이터 삭제';
  static const String savedApplications = '저장된 공고';
  static const String info = '정보';
  static const String appVersion = '앱 버전';
  static const String developerInfo = '개발자 정보';
  static const String sendFeedback = '피드백 보내기';
  static const String count = '개';
}
