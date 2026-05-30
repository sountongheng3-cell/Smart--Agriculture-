import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_urls.dart';
import 'api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService — handles register, login, logout, session persistence
// Uses SharedPreferences to store user locally (works with dummyjson)
// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUser = 'user_data';

  // ── Register ────────────────────────────────────────────────────────────
  // dummyjson /users/add accepts POST and returns a fake new user — we save
  // the data locally so the app behaves like a real auth system.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // Basic validation
    if (name.trim().isEmpty) throw Exception('Please enter your name.');
    if (email.trim().isEmpty) throw Exception('Please enter your email.');
    if (!email.contains('@')) throw Exception('Please enter a valid email.');
    if (password.length < 6)
      throw Exception('Password must be at least 6 characters.');
    if (phone.trim().isEmpty)
      throw Exception('Please enter your phone number.');

    // Check if already registered locally
    final existing = await getUser();
    if (existing != null && existing['email'] == email.trim()) {
      throw Exception(
        'An account with this email already exists. Please log in.',
      );
    }

    // Call dummyjson (returns fake id — that's fine for demo)
    final body = {
      'firstName': name.trim().split(' ').first,
      'lastName': name.trim().split(' ').length > 1
          ? name.trim().split(' ').last
          : '',
      'email': email.trim(),
      'password': password,
      'phone': phone.trim(),
    };

    final response = await ApiService.postRequest(ApiUrls.register, body);

    // Build user object to store locally
    final user = {
      'id': response['id'] ?? 1,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password, // stored for local login check
      'avatar': '',
    };

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
    await prefs.setBool(_keyIsLoggedIn, true);

    return user;
  }

  // ── Login ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) throw Exception('Please enter your email.');
    if (password.trim().isEmpty) throw Exception('Please enter your password.');

    // Check against locally stored user first
    final stored = await getUser();
    if (stored != null) {
      if (stored['email'] == email.trim() && stored['password'] == password) {
        // Local login success
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        return stored;
      } else if (stored['email'] == email.trim()) {
        throw Exception('Incorrect password.');
      }
    }

    // Fallback: try dummyjson (works with their demo accounts)
    try {
      final body = {'username': email.trim(), 'password': password};
      final response = await ApiService.postRequest(ApiUrls.login, body);

      final user = {
        'id': response['id'] ?? 0,
        'name': '${response['firstName'] ?? ''} ${response['lastName'] ?? ''}'
            .trim(),
        'email': response['email'] ?? email.trim(),
        'phone': response['phone'] ?? '',
        'password': password,
        'avatar': response['image'] ?? '',
        'token': response['token'] ?? '',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, jsonEncode(user));
      await prefs.setBool(_keyIsLoggedIn, true);

      return user;
    } catch (_) {
      throw Exception('No account found. Please register first.');
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    // Keep user data so they can log back in
  }

  // ── Session checks ───────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Update profile ───────────────────────────────────────────────────────
  static Future<void> updateUser(Map<String, dynamic> updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(updated));
  }
}
