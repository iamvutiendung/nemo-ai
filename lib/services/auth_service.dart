import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseService.client;

  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.id;

  static String? get email => currentUser?.email;
  static Future<void> signInWithFacebook() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.facebook,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'credits': 10,
        'plan': 'free',
      });
    }

    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  static Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'http://localhost:58715',
    );
  }
  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;

    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}