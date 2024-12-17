import 'package:flutter/material.dart';
import '../models/member.dart';
import '../screen/services/member_service.dart';

class AuthProvider extends ChangeNotifier {
  final _memberService = MemberService();
  Member? _currentUser;
  bool _isLoading = false;

  Member? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _memberService.getProfile();
      _currentUser = profile;
    } catch (e) {
      print('Error loading profile: $e');
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

  void logout() {
    _memberService.logout();
    _currentUser = null;
    notifyListeners();
  }
} 