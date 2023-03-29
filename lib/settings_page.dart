import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/preferred_video_resolution.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

const List<PreferredVideoResolution> preferredResolutions = [
  PreferredVideoResolution.p360,
  PreferredVideoResolution.p480,
  PreferredVideoResolution.p720,
  PreferredVideoResolution.p1080,
  PreferredVideoResolution.p1440,
  PreferredVideoResolution.p2160,
  PreferredVideoResolution.maximum
];

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box("settings").listenable(),
        builder: (context, box, widget) {
          final automaticLaunch = box.get(
            "automaticLaunch",
            defaultValue: false,
          );
          final preferredQuality = box.get("preferredQuality",
              defaultValue: PreferredVideoResolution.p1080);

          return ListView(
            children: [
              SwitchListTile(
                title: const Text(
                  "Automatically launch player with preferred stream quality",
                ),
                value: automaticLaunch,
                onChanged: (value) {
                  box.put("automaticLaunch", value);
                },
              ),
              ListTile(
                title: const Text("Preferred streaming quality"),
                enabled: automaticLaunch,
                trailing: DropdownButton<PreferredVideoResolution>(
                  value: preferredQuality,
                  items: preferredResolutions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.label),
                        ),
                      )
                      .toList(),
                  onChanged: automaticLaunch
                      ? (value) {
                          if (value != null) {
                            box.put("preferredQuality", value);
                          }
                        }
                      : null,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
