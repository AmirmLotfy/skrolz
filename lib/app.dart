import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_theme.dart';

class SkrolzApp extends StatelessWidget {
  const SkrolzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return MaterialApp.router(
      title: 'Skrolz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: locale,
      routerConfig: createAppRouter(),
    );
  }
}
