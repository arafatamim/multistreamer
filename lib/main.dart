import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/pages/home_page.dart';
import 'package:multistreamer/pages/settings_page.dart';
import 'package:multistreamer/preferred_video_resolution.dart';

// https://www.pbs.org/video/nova-labs-fossils-rocking-earth

void main(List<String> argv) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PreferredVideoResolutionAdapter());
  Hive.registerAdapter(AppThemeAdapter());
  await Hive.openBox("settings");
  try {
    final initialLink = Platform.isAndroid
        ? await AppLinks().getInitialLink()
        : Uri.parse(argv.first);
    runApp(MyApp(initialUrl: initialLink));
  } on StateError {
    runApp(const MyApp());
  }
}

const _defaultDarkColorScheme = ColorScheme.dark(
  primary: Colors.pink,
  secondary: Colors.pink,
  tertiary: Colors.pink,
);

const _defaultLightColorScheme = ColorScheme.light(
  primary: Colors.pink,
  secondary: Colors.pink,
  tertiary: Colors.pink,
);

const title = "MultiStreamer";

class MyApp extends StatelessWidget {
  final Uri? initialUrl;

  const MyApp({super.key, this.initialUrl});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
      },
      child: ValueListenableBuilder(
        valueListenable: Hive.box("settings").listenable(keys: ["appTheme"]),
        builder: (context, box, child) => DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            final appTheme = box.get(
              "appTheme",
              defaultValue: AppTheme.system,
            );

            return MaterialApp(
              title: title,
              themeMode: appTheme == AppTheme.system
                  ? ThemeMode.system
                  : appTheme == AppTheme.light
                      ? ThemeMode.light
                      : ThemeMode.dark,
              theme: ThemeData(
                colorScheme: lightColorScheme ?? _defaultLightColorScheme,
                useMaterial3: true,
                inputDecorationTheme: InputDecorationTheme(
                  fillColor: Colors.grey.shade300,
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
                useMaterial3: true,
                inputDecorationTheme: InputDecorationTheme(
                  fillColor: Colors.grey.shade800,
                ),
              ),
              routes: {
                "/": (context) => HomePage(
                      title: title,
                      initialUrl: initialUrl,
                    ),
                "/settings": (context) => const SettingsPage()
              },
            );
          },
        ),
      ),
    );
  }
}
