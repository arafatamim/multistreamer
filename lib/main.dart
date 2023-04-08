import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/home_page.dart';
import 'package:multistreamer/preferred_video_resolution.dart';
import 'package:multistreamer/settings_page.dart';

void main(List<String> argv) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PreferredVideoResolutionAdapter());
  await Hive.openBox("settings");
  try {
    final initialLink = Platform.isAndroid
        ? await AppLinks().getInitialAppLink()
        : Uri.parse(argv.first);
    runApp(MyApp(initialUrl: initialLink));
  } on StateError {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  final Uri? initialUrl;

  const MyApp({super.key, this.initialUrl});

  @override
  Widget build(BuildContext context) {
    const title = "MultiStreamer";
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
      },
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            surface: Colors.transparent,
            secondary: Colors.pink,
            primary: Colors.pink,
          ),
        ),
        routes: {
          "/": (context) => HomePage(
                title: title,
                initialUrl: initialUrl,
              ),
          "/settings": (context) => const SettingsPage()
        },
      ),
    );
  }
}
