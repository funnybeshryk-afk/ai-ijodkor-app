import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/locale_controller.dart';
import 'core/supabase_init.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final supabaseReady = await initSupabase();

  runApp(
    ProviderScope(
      // Errors (e.g. no network) are shown with a retry button instead.
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (supabaseReady)
          supabaseClientProvider.overrideWithValue(Supabase.instance.client),
      ],
      child: const AiIjodkorApp(),
    ),
  );
}
