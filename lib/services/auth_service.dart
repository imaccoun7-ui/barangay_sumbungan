import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'backend/barangay_backend.dart';

/// Handles sign-in, registration, password reset and session restoration.
///
/// The signed-in user id is stored on the device so a resident stays signed in
/// after the app is closed and reopened.
class AuthService {
  AuthService(this._backend);

  static const String _sessionKey = 'barangay_sumbungan_session_user';

  final BarangayBackend _backend;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<UserModel?> restoreSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id = prefs.getString(_sessionKey);
      if (id == null || id.isEmpty) return null;
      final UserModel? user = await _backend.findUserById(id);
      if (user == null || !user.isActive) return null;
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSession(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, userId);
    } catch (_) {
      // Session persistence is best effort; sign-in still succeeds.
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final UserModel? user = await _backend.authenticate(email, password);
    if (user == null) {
      throw BackendException('Incorrect email or password. Please try again.');
    }
    _currentUser = user;
    await _saveSession(user.id);
    return user;
  }

  Future<UserModel> registerResident({
    required String fullName,
    required String email,
    required String password,
    required String contactNumber,
    required String address,
    String householdInfo = '',
  }) async {
    final UserModel user = await _backend.createResident(
      fullName: fullName,
      email: email,
      password: password,
      contactNumber: contactNumber,
      address: address,
      householdInfo: householdInfo,
    );
    _currentUser = user;
    await _saveSession(user.id);
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {
      // The in-memory session is already cleared.
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _backend.requestPasswordReset(email);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final UserModel? user = _currentUser;
    if (user == null) throw BackendException('You are not signed in.');
    await _backend.changePassword(user.id, currentPassword, newPassword);
  }

  Future<UserModel> updateProfile(UserModel updated) async {
    await _backend.updateProfile(updated);
    _currentUser = updated;
    return updated;
  }
}
