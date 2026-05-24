import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/screens/dashboard_screen.dart';
import 'package:metro_next_taipei/services/theme_service.dart';
import 'package:metro_next_taipei/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();
  await LocaleService.instance.init();
  runApp(
    DynamicColorBuilder(
      builder: (ColorScheme? light, ColorScheme? dark) {
        return MyApp(light: light, dark: dark);
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final ColorScheme? light;
  final ColorScheme? dark;
  const MyApp({super.key, this.light, this.dark});

  @override
  Widget build(BuildContext context) {
    const transitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    );

    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, LocaleService.instance]),
      builder: (context, _) {
        final themeService = ThemeService.instance;
        
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (themeService.dynamicColorEnabled && light != null && dark != null) {
          lightScheme = light!;
          
          final darkSurface = dark!.surface;
          final darkOnSurface = dark!.onSurface;
          darkScheme = dark!.copyWith(
            surfaceContainerLowest: Color.alphaBlend(darkOnSurface.withValues(alpha: 0.01), darkSurface),
            surfaceContainerLow: Color.alphaBlend(darkOnSurface.withValues(alpha: 0.03), darkSurface),
            surfaceContainer: Color.alphaBlend(darkOnSurface.withValues(alpha: 0.06), darkSurface),
            surfaceContainerHigh: Color.alphaBlend(darkOnSurface.withValues(alpha: 0.09), darkSurface),
            surfaceContainerHighest: Color.alphaBlend(darkOnSurface.withValues(alpha: 0.12), darkSurface),
          );
        } else {
          final seedColor = themeService.currentSeedColor;
          lightScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
        }

        ThemeData customDarkTheme;
        if (themeService.oledEnabled) {
          customDarkTheme = ThemeData.from(
            colorScheme: darkScheme.copyWith(
              surface: Colors.black,
              surfaceContainer: const Color(0xFF121212),
              surfaceContainerHigh: const Color(0xFF1C1C1E),
              surfaceContainerHighest: const Color(0xFF2C2C2E),
              surfaceContainerLow: const Color(0xFF0A0A0A),
              surfaceContainerLowest: Colors.black,
              onSurface: Colors.white,
              onSurfaceVariant: const Color(0xFF8E8E93),
            ),
            useMaterial3: true,
          ).copyWith(
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF121212),
            pageTransitionsTheme: transitions,
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          customDarkTheme = ThemeData.from(
            colorScheme: darkScheme,
            useMaterial3: true,
          ).copyWith(
            pageTransitionsTheme: transitions,
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }

        ThemeMode flutterThemeMode;
        switch (themeService.themeMode) {
          case 'light':
            flutterThemeMode = ThemeMode.light;
            break;
          case 'dark':
            flutterThemeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            flutterThemeMode = ThemeMode.system;
            break;
        }

        return MaterialApp(
          title: 'MetroNext',
          debugShowCheckedModeBanner: false,
          locale: LocaleService.instance.currentLocale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('zh'),
            Locale('en'),
          ],
          theme: ThemeData.from(
            colorScheme: lightScheme,
            useMaterial3: true,
          ).copyWith(
            pageTransitionsTheme: transitions,
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          darkTheme: customDarkTheme,
          themeMode: flutterThemeMode,
          home: const MetroDashboard(),
        );
      },
    );
  }
}

