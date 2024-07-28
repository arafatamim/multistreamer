import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/preferred_video_resolution.dart';
import 'package:multistreamer/utils.dart';

class SettingsSectionTile extends StatelessWidget {
  final String title;

  const SettingsSectionTile({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6, left: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
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

@HiveType(typeId: 3)
enum AppTheme {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  int get typeId => 3;

  @override
  AppTheme read(BinaryReader reader) {
    switch (reader.read()) {
      case "system":
        return AppTheme.system;
      case "light":
        return AppTheme.light;
      case "dark":
        return AppTheme.dark;
      default:
        throw "Invalid AppTheme";
    }
  }

  @override
  void write(BinaryWriter writer, AppTheme obj) {
    writer.write(obj.toString().split(".").last);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box("settings").listenable(),
        builder: (context, box, widget) {
          final AppTheme appTheme = box.get(
            "appTheme",
            defaultValue: AppTheme.system,
          );
          final bool automaticLaunch = box.get(
            "automaticLaunch",
            defaultValue: false,
          );
          final PreferredVideoResolution preferredQuality = box.get(
            "preferredQuality",
            defaultValue: PreferredVideoResolution.p1080,
          );
          final bool legacyServerConnect = box.get(
            "legacyServerConnect",
            defaultValue: false,
          );
          final bool noCheckCertificates = box.get(
            "noCheckCertificates",
            defaultValue: false,
          );
          final String? extraArgs = box.get("extraArgs");

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
              ),
              const SettingsSectionTile(title: "Appearance"),
              ListTile(
                title: const Text("Theme"),
                trailing: DropdownButton<AppTheme>(
                  value: appTheme,
                  items: const [
                    DropdownMenuItem(
                      value: AppTheme.system,
                      child: Text("System"),
                    ),
                    DropdownMenuItem(
                      value: AppTheme.light,
                      child: Text("Light"),
                    ),
                    DropdownMenuItem(
                      value: AppTheme.dark,
                      child: Text("Dark"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      box.put("appTheme", value);
                    }
                  },
                ),
              ),
              const SettingsSectionTile(title: "yt-dlp options"),
              CheckboxListTile(
                title: const Text("Legacy server connection"),
                subtitle: const Text(
                  "Explicitly allow HTTPS connection to servers "
                  "that do not support RFC 5746 secure renegotiation",
                ),
                value: legacyServerConnect,
                onChanged: (value) {
                  if (value != null) {
                    box.put("legacyServerConnect", value);
                  }
                },
              ),
              CheckboxListTile(
                title: const Text("Suppress HTTPS certificate validation"),
                value: noCheckCertificates,
                onChanged: (value) {
                  if (value != null) {
                    box.put("noCheckCertificates", value);
                  }
                },
              ),
              TextFieldListTile(
                title: const Text("Extra arguments"),
                subtitle: extraArgs,
                emptyText: "Additional command-line arguments"
                    " to be passed to yt-dlp."
                    " NOTE: This is for advanced users.",
                hintText: "e.g. --force-ipv6 --sponsorblock-mark all",
                onSubmit: (value) {
                  box.put("extraArgs", value);
                },
                onClear: () {
                  box.delete("extraArgs");
                },
              ),
              const SettingsSectionTile(title: "About"),
              ListTile(
                title: const Text("Version"),
                subtitle: const Text("1.1.0"),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "MultiStreamer",
                    applicationVersion: "1.1.0",
                    applicationLegalese: "© 2024 Tamim Arafat",
                    children: [
                      const Text("Watch videos from numerous websites"),
                    ],
                    applicationIcon: Image.asset(
                      "assets/images/app_icon.png",
                      width: 64,
                      height: 64,
                    ),
                    // TODO: add youtube-dl license
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class TextFieldListTile extends StatefulWidget {
  final Widget? title;
  final String? subtitle;
  final String? hintText;
  final ValueSetter<String>? onSubmit;
  final VoidCallback? onClear;
  final String? emptyText;

  const TextFieldListTile({
    super.key,
    this.title,
    this.hintText,
    this.onSubmit,
    this.onClear,
    this.emptyText,
    required this.subtitle,
  });

  @override
  State<TextFieldListTile> createState() => _TextFieldListTileState();
}

class _TextFieldListTileState extends State<TextFieldListTile> {
  late String? subtitle;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    subtitle = widget.subtitle;
    _textEditingController = TextEditingController(text: subtitle);
    super.initState();
  }

  void _submit() {
    final text = _textEditingController.text;
    if (text == "") return;
    setState(() {
      subtitle = text;
    });
    widget.onSubmit?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle:
          subtitle.map((v) => Text(v)) ?? widget.emptyText.map((v) => Text(v)),
      onTap: () {
        _textEditingController.text = subtitle ?? "";
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: widget.title,
              content: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                ),
                onEditingComplete: () {
                  _submit();
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () {
                    setState(() {
                      subtitle = null;
                    });
                    _textEditingController.clear();
                    widget.onClear?.call();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    _submit();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
