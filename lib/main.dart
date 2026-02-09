import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skrolz_app/app.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/sdk_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppSupabase.init();
  await initSdks();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/l10n',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: SkrolzApp(),
      ),
    ),
  );
}
