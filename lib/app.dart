import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_scope.dart';
import 'providers/app_state.dart';

class BarangaySumbunganApp extends StatelessWidget {
  const BarangaySumbunganApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (BuildContext context, Widget? child) {
          // Keeps text scaling within a usable range on small Android screens.
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaler: data.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.3,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
