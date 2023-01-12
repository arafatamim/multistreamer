import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_links/app_links.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:multistreamer/fetcher/youtube_dl.dart';
import "package:multistreamer/utils.dart";
import 'package:multistreamer/video_info.dart';

final appLinks = AppLinks();

void main(List<String> argv) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final initialLink = Platform.isAndroid
        ? await appLinks.getInitialAppLink()
        : Uri.parse(argv.first);
    runApp(MyApp(initialUrl: initialLink));
  } on StateError {
    runApp(const MyApp());
  }
}

Future<void> launchIntent({required String url, required String title}) {
  final intent = AndroidIntent(
    action: "action_view",
    data: url,
    type: "video/*",
    flags: [
      Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
      Flag.FLAG_GRANT_PREFIX_URI_PERMISSION,
      Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
      Flag.FLAG_GRANT_READ_URI_PERMISSION
    ],
    arguments: {"title": title},
  );
  return intent.launch();
}

class Boilerplate extends StatelessWidget {
  final ValueSetter<String> onSubmit;
  final TextEditingController? controller;
  final Widget child;

  const Boilerplate({
    super.key,
    required this.onSubmit,
    required this.child,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Header(
            onSubmit: onSubmit,
            textEditingController: controller,
            key: key,
          ),
          Expanded(child: child)
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  final TextEditingController? textEditingController;
  final ValueSetter<String> onSubmit;
  const Header({
    super.key,
    this.textEditingController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Share or enter a url to play...",
            ),
            textInputAction: TextInputAction.go,
            onSubmitted: onSubmit,
          ),
        ),
        IconButton(
          onPressed: () {
            if (textEditingController != null) {
              onSubmit(textEditingController!.text);
            }
          },
          icon: const Icon(Icons.arrow_circle_right),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  final Uri? initialUrl;

  const MyApp({super.key, this.initialUrl});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp(
        title: 'MultiStreamer',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            surface: Colors.transparent,
            secondary: Colors.pink,
            primary: Colors.pink,
          ),
        ),
        home: MyHomePage(
          title: 'MultiStreamer',
          initialUrl: initialUrl,
        ),
      ),
    );
  }
}

class VideoHeaders extends StatelessWidget {
  final VideoInfo data;

  const VideoHeaders({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          [data.provider, data.uploader, data.uploaderId]
              .where((element) => element != null)
              .join(" - ")
              .toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.title,
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}

class VideoSources extends StatelessWidget {
  final VideoInfo data;

  const VideoSources({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final item in data.formats.reversed) ...[
          ListTile(
            title: Text(item.resolution ?? "Unknown resolution"),
            subtitle: Text(
              [
                item.displayFormat,
                item.bytes.map(formatSize),
              ].where((element) => element != null).join(" - "),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.black12,
            onTap: () async {
              await launchIntent(
                url: item.url,
                title: data.title,
              );
            },
          ),
          const SizedBox(height: 8)
        ]
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  final Uri? initialUrl;
  const MyHomePage({super.key, required this.title, this.initialUrl});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final StreamSubscription _incomingLinksSub;
  late final TextEditingController _textEditingController;
  late final StreamController<Deferred<VideoInfo>> _dataStreamController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Deferred<VideoInfo>>(
        initialData: const Deferred.idle(),
        stream: _dataStreamController.stream,
        builder: (context, snapshot) {
          final data = snapshot.data as Deferred<VideoInfo>;
          return data.when(
            success: (data) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                launchIntent(
                  url: data.formats.last.url,
                  title: data.title,
                );
              });
              return Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Header(
                            onSubmit: _setUrl,
                            textEditingController: _textEditingController,
                          ),
                          const Spacer(),
                          VideoHeaders(data: data),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: VideoSources(data: data),
                    ),
                  )
                ],
              );
            },
            error: (err, stackTrace) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$err"),
                    duration: const Duration(seconds: 15),
                  ),
                );
              });
              return Boilerplate(
                controller: _textEditingController,
                onSubmit: _setUrl,
                child: const Center(
                  child: Icon(Icons.error),
                ),
              );
            },
            inProgress: () => Boilerplate(
              controller: _textEditingController,
              onSubmit: _setUrl,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            idle: () => Boilerplate(
              controller: _textEditingController,
              onSubmit: _setUrl,
              child: Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _incomingLinksSub.cancel();
    _textEditingController.dispose();
    _dataStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final initialUrl = widget.initialUrl;

    _textEditingController = TextEditingController(
      text: initialUrl?.toString(),
    );
    _dataStreamController = StreamController();

    if (initialUrl != null) {
      _dataStreamController.add(const Deferred.inProgress());
      _fetchJson(initialUrl);
    } else {
      _dataStreamController.add(const Deferred.idle());
    }

    if (Platform.isAndroid) {
      _incomingLinksSub = appLinks.uriLinkStream.listen((link) {
        _dataStreamController.add(const Deferred.inProgress());
        setState(() {
          _textEditingController.text = link.toString();
        });
        _fetchJson(link);
      }, onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$error")),
        );
      });
    }
  }

  void _fetchJson(Uri url) async {
    VideoInfo videoInfo;

    try {
      videoInfo = await YouTubeDL().fetchVideoInfo(url);
      _dataStreamController.add(Deferred.success(videoInfo));
    } catch (e, stack) {
      _dataStreamController.add(Deferred.error(e, stack));
    }
  }

  void _setUrl(String value) {
    try {
      final url = Uri.parse(value);
      _dataStreamController.add(const Deferred.inProgress());
      _fetchJson(url);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not a valid URL!")),
      );
    }
  }
}
