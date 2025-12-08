// StorageService
// 로컬 데이터 저장소 관리 서비스
// - 공고 데이터 저장/불러오기
// - SharedPreferences를 사용하여 JSON 형태로 저장

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application.dart';

class StorageService {
  static const String _applicationIdsKey = 'application_ids';

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
}
