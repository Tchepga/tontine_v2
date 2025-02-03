import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'models/enum/role.dart';
import 'models/member.dart';
import '../screen/services/dto/member_dto.dart';
import '../screen/services/member_service.dart';

class AuthProvider extends ChangeNotifier {
  final _memberService = MemberService();
  final _storage = GetStorage();
  static const String KEY_PROFILE = 'user_profile';
  
  Member? _currentUser;
  bool _isLoading = false;
  Logger logger = Logger('AuthProvider');

  Member? get currentUser {
    if (_currentUser != null) return _currentUser;
    
    // Vérifier d'abord dans le storage
    try {
      final storedProfile = _storage.read(KEY_PROFILE);
      if (storedProfile != null) {
        _currentUser = Member.fromJson(jsonDecode(storedProfile));
        return _currentUser;
      }
    } catch (e) {
      logger.warning('Error reading stored profile: $e');
    }

    // Ne pas faire d'appel API dans le getter
    return _currentUser;
  }

  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStoredProfile();
  }

  void _loadStoredProfile() {
    try {
      final storedProfile = _storage.read(KEY_PROFILE);
      if (storedProfile != null) {
        _currentUser = Member.fromJson(jsonDecode(storedProfile));
        notifyListeners();
      }
    } catch (e) {
      logger.severe('Error loading stored profile: $e');
    }
  }

  Future<void> _saveProfile(Member profile) async {
    try {
      await _storage.write(KEY_PROFILE, jsonEncode(profile.toJson()));
      _currentUser = profile;
    } catch (e) {
      logger.severe('Error saving profile: $e');
    }
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _memberService.getProfile();
      if (profile != null) {
        await _saveProfile(profile);
      }
    } catch (e) {
      logger.severe('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _memberService.login(username, password);
      if (success) {
        await loadProfile();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _memberService.getProfile();
      if (profile != null) {
        await _saveProfile(profile);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _memberService.logout();
    _storage.remove(KEY_PROFILE);
    _currentUser = null;
    notifyListeners();
  }

  bool isPresident() {
    return _currentUser?.user?.roles?.contains(Role.PRESIDENT) ?? false;
  }

  Future<bool> register(CreateMemberDto memberDto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _memberService.register(memberDto);
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> registerPresident(CreateMemberDto memberDto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final statusCode = await _memberService.registerPresident(memberDto);
      return statusCode;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Member?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    // Vérifier d'abord dans le storage
    try {
      final storedProfile = _storage.read(KEY_PROFILE);
      if (storedProfile != null) {
        _currentUser = Member.fromJson(jsonDecode(storedProfile));
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      logger.warning('Error reading stored profile: $e');
    }

    // Si pas dans le storage et token valide, charger depuis l'API
    final isValid = await _memberService.hasValidToken();
    if (isValid) {
      await loadProfile();
      notifyListeners();
    } else {
      // Si le token n'est pas valide, nettoyer le storage
      logout();
    }

    return _currentUser;
  }
}

