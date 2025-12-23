// StorageService
// 로컬 데이터 저장소 관리 서비스
// - 공고 데이터 저장/불러오기
// - SharedPreferences를 사용하여 JSON 형태로 저장

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application.dart';
import '../models/archive_folder.dart';

class StorageService {
  static const String _applicationIdsKey = 'application_ids';
  static const String _archiveFolderIdsKey = 'archive_folder_ids';

  // 싱글톤 패턴
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 모든 공고 가져오기
  Future<List<Application>> getAllApplications() async {
    if (_prefs == null) {
      await init();
    }

    try {
      final idsJson = _prefs!.getString(_applicationIdsKey);
      if (idsJson == null || idsJson.isEmpty) {
        return [];
      }

      final List<dynamic> ids = jsonDecode(idsJson);
      final List<Application> applications = [];

      for (final id in ids) {
        final applicationJson = _prefs!.getString('application_$id');
        if (applicationJson != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(applicationJson);
            applications.add(Application.fromJson(json));
          } catch (e) {
            // 잘못된 데이터는 건너뛰기
            continue;
          }
        }
      }

      return applications;
    } catch (e) {
      return [];
    }
  }

  // 공고 저장
  Future<bool> saveApplication(Application application) async {
    if (_prefs == null) {
      await init();
    }

    try {
      // Application을 JSON으로 변환하여 저장
      final applicationJson = jsonEncode(application.toJson());
      await _prefs!.setString('application_${application.id}', applicationJson);

      // ID 목록 업데이트
      final idsJson = _prefs!.getString(_applicationIdsKey);
      List<dynamic> ids = idsJson != null ? jsonDecode(idsJson) : [];

      if (!ids.contains(application.id)) {
        ids.add(application.id);
        await _prefs!.setString(_applicationIdsKey, jsonEncode(ids));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 공고 삭제
  Future<bool> deleteApplication(String id) async {
    if (_prefs == null) {
      await init();
    }

    try {
      // Application 데이터 삭제
      await _prefs!.remove('application_$id');

      // ID 목록에서 제거
      final idsJson = _prefs!.getString(_applicationIdsKey);
      if (idsJson != null) {
        List<dynamic> ids = jsonDecode(idsJson);
        ids.remove(id);
        await _prefs!.setString(_applicationIdsKey, jsonEncode(ids));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 공고 ID로 가져오기
  Future<Application?> getApplicationById(String id) async {
    if (_prefs == null) {
      await init();
    }

    try {
      final applicationJson = _prefs!.getString('application_$id');
      if (applicationJson == null) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(applicationJson);
      return Application.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // 모든 공고 삭제 (테스트용)
  Future<bool> clearAllApplications() async {
    if (_prefs == null) {
      await init();
    }

    try {
      final idsJson = _prefs!.getString(_applicationIdsKey);
      if (idsJson != null) {
        final List<dynamic> ids = jsonDecode(idsJson);
        for (final id in ids) {
          await _prefs!.remove('application_$id');
        }
      }
      await _prefs!.remove(_applicationIdsKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 보관함 제외한 공고만 가져오기 (활성 공고)
  Future<List<Application>> getActiveApplications() async {
    final allApplications = await getAllApplications();
    return allApplications.where((app) => !app.isArchived).toList();
  }

  // 보관함 공고만 가져오기
  Future<List<Application>> getArchivedApplications({String? folderId}) async {
    final allApplications = await getAllApplications();
    final archived = allApplications.where((app) => app.isArchived).toList();
    
    if (folderId == null) {
      // 폴더가 지정되지 않으면 폴더에 속하지 않은 보관함 공고만 반환
      return archived.where((app) => app.archiveFolderId == null).toList();
    } else {
      // 특정 폴더의 공고만 반환
      return archived.where((app) => app.archiveFolderId == folderId).toList();
    }
  }

  // 모든 보관함 공고 가져오기 (폴더 구분 없이)
  Future<List<Application>> getAllArchivedApplications() async {
    final allApplications = await getAllApplications();
    return allApplications.where((app) => app.isArchived).toList();
  }

  // 공고를 보관함으로 이동
  Future<bool> moveApplicationToArchive(String applicationId, {String? folderId}) async {
    if (_prefs == null) {
      await init();
    }

    try {
      final application = await getApplicationById(applicationId);
      if (application == null) {
        return false;
      }

      // 보관함으로 이동 시 알림 설정 비활성화
      final updatedNotificationSettings = application.notificationSettings.copyWith(
        deadlineNotification: false,
        announcementNotification: false,
        interviewNotification: false,
      );

      final updatedApplication = application.copyWith(
        isArchived: true,
        archiveFolderId: folderId,
        notificationSettings: updatedNotificationSettings,
        updatedAt: DateTime.now(),
      );

      return await saveApplication(updatedApplication);
    } catch (e) {
      return false;
    }
  }

  // 여러 공고를 보관함으로 이동
  Future<bool> moveApplicationsToArchive(List<String> applicationIds, {String? folderId}) async {
    bool allSuccess = true;
    for (final id in applicationIds) {
      final success = await moveApplicationToArchive(id, folderId: folderId);
      if (!success) {
        allSuccess = false;
      }
    }
    return allSuccess;
  }

  // 보관함에서 복원
  Future<bool> restoreApplicationFromArchive(String applicationId) async {
    if (_prefs == null) {
      await init();
    }

    try {
      final application = await getApplicationById(applicationId);
      if (application == null) {
        return false;
      }

      final updatedApplication = application.copyWith(
        isArchived: false,
        archiveFolderId: null,
        updatedAt: DateTime.now(),
      );

      return await saveApplication(updatedApplication);
    } catch (e) {
      return false;
    }
  }

  // 여러 공고를 보관함에서 복원
  Future<bool> restoreApplicationsFromArchive(List<String> applicationIds) async {
    bool allSuccess = true;
    for (final id in applicationIds) {
      final success = await restoreApplicationFromArchive(id);
      if (!success) {
        allSuccess = false;
      }
    }
    return allSuccess;
  }

  // 모든 보관함 폴더 가져오기
  Future<List<ArchiveFolder>> getAllArchiveFolders() async {
    if (_prefs == null) {
      await init();
    }

    try {
      final foldersJson = _prefs!.getString(_archiveFolderIdsKey);
      if (foldersJson == null || foldersJson.isEmpty) {
        return [];
      }

      final List<dynamic> ids = jsonDecode(foldersJson);
      final List<ArchiveFolder> folders = [];

      for (final id in ids) {
        final folderJson = _prefs!.getString('archive_folder_$id');
        if (folderJson != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(folderJson);
            folders.add(ArchiveFolder.fromJson(json));
          } catch (e) {
            // 잘못된 데이터는 건너뛰기
            continue;
          }
        }
      }

      // 생성일 기준으로 정렬
      folders.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return folders;
    } catch (e) {
      return [];
    }
  }

  // 보관함 폴더 저장
  Future<bool> saveArchiveFolder(ArchiveFolder folder) async {
    if (_prefs == null) {
      await init();
    }

    try {
      // 폴더를 JSON으로 변환하여 저장
      final folderJson = jsonEncode(folder.toJson());
      await _prefs!.setString('archive_folder_${folder.id}', folderJson);

      // ID 목록 업데이트
      final idsJson = _prefs!.getString(_archiveFolderIdsKey);
      List<dynamic> ids = idsJson != null ? jsonDecode(idsJson) : [];

      if (!ids.contains(folder.id)) {
        ids.add(folder.id);
        await _prefs!.setString(_archiveFolderIdsKey, jsonEncode(ids));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 보관함 폴더 삭제
  Future<bool> deleteArchiveFolder(String folderId) async {
    if (_prefs == null) {
      await init();
    }

    try {
      // 폴더 데이터 삭제
      await _prefs!.remove('archive_folder_$folderId');

      // ID 목록에서 제거
      final idsJson = _prefs!.getString(_archiveFolderIdsKey);
      if (idsJson != null) {
        List<dynamic> ids = jsonDecode(idsJson);
        ids.remove(folderId);
        await _prefs!.setString(_archiveFolderIdsKey, jsonEncode(ids));
      }

      // 해당 폴더에 속한 공고들을 보관함 루트로 이동
      final archivedApps = await getArchivedApplications(folderId: folderId);
      for (final app in archivedApps) {
        await moveApplicationToArchive(app.id, folderId: null);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 보관함 통계 제외 설정 키
  static const String _excludeArchivedFromStatsKey = 'exclude_archived_from_stats';

  // 보관함 통계 제외 설정 가져오기
  Future<bool> getExcludeArchivedFromStatistics() async {
    if (_prefs == null) {
      await init();
    }
    // 기본값: true (보관함 제외)
    return _prefs?.getBool(_excludeArchivedFromStatsKey) ?? true;
  }

  // 보관함 통계 제외 설정 저장
  Future<bool> setExcludeArchivedFromStatistics(bool value) async {
    if (_prefs == null) {
      await init();
    }
    try {
      return await _prefs!.setBool(_excludeArchivedFromStatsKey, value);
    } catch (e) {
      return false;
    }
  }
}
