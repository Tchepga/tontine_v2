import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'models/enum/role.dart';
import 'models/member.dart';
import '../screen/services/dto/member_dto.dart';
import '../screen/services/member_service.dart';

class AuthProvider extends ChangeNotifier {
  final _memberService = MemberService();
  Member? _currentUser;
  bool _isLoading = false;
  Logger logger = Logger('AuthProvider');

  Member? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _memberService.getProfile();
      _currentUser = profile;
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
      _currentUser = profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _memberService.logout();
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
}

