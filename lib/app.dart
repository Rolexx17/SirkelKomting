import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

/// Akar aplikasi Sirkel: MaterialApp dengan tema Material 3 dan named routes.
class SirkelApp extends StatelessWidget {
  const SirkelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
