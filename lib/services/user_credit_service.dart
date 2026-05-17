import 'package:supabase_flutter/supabase_flutter.dart';

class UserCreditService {
  static final _client = Supabase.instance.client;

  static Future<int> getCredits() async {
    final user = _client.auth.currentUser;

    if (user == null) return 0;

    try {
      final data = await _client
          .from('profiles')
          .select('credits')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        await _client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'credits': 10,
          'plan': 'free',
        });

        return 10;
      }

      return data['credits'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> addCredits(int amount) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final current = await getCredits();
    final newCredits = current + amount;

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'credits': newCredits,
      'plan': 'pro',
    });
  }

  static Future<void> removeCredits(int amount) async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    final current = await getCredits();
    final newCredits = current - amount;

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'credits': newCredits < 0 ? 0 : newCredits,
    });
  }

  static Future<void> setCredits(int amount) async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'credits': amount,
    });
  }

  static Future<bool> spendCredits(int amount) async {
    final user = _client.auth.currentUser;

    if (user == null) return false;

    final currentCredits = await getCredits();

    if (currentCredits < amount) {
      return false;
    }

    final newCredits = currentCredits - amount;

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'credits': newCredits,
    });

    return true;
  }
}