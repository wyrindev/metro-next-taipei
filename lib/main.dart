import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:metro_next_taipei/screens/dashboard.dart';

void main() {
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

    return MaterialApp(
      title: 'MetroNext',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(colorScheme: light ?? const ColorScheme.light())
          .copyWith(
        pageTransitionsTheme: transitions,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.from(colorScheme: dark ?? const ColorScheme.dark())
          .copyWith(
        pageTransitionsTheme: transitions,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MetroDashboard(),
    );
  }
}
