import 'package:supabase_flutter/supabase_flutter.dart';

/// Kredensial diambil dari --dart-define saat build/run, BUKAN di-hardcode.
/// Contoh menjalankan:
///   flutter run --dart-define=SUPABASE_URL=https://tajcrphcxclevbwupybp.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
