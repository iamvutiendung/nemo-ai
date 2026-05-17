import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://oueuxxxfyjhttlawtmyy.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91ZXV4eHhmeWpodHRsYXd0bXl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMzQzMTEsImV4cCI6MjA5MzkxMDMxMX0.LSp4UYiMF3Jq6G8qJ3KF4wspW2hNZdKLQuq9V1BRIEE',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}