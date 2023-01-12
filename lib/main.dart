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
            focusNode: FocusNode(
              onKey: (node, key) {
                if (key is RawKeyDownEvent) {
                  if (key.logicalKey == LogicalKeyboardKey.arrowDown) {
                    node.nextFocus();
                  }
                  if (key.logicalKey == LogicalKeyboardKey.arrowUp) {
                    node.previousFocus();
                  }
                }
                return KeyEventResult.ignored;
              },
            ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Under construction!"),
              ),
            );
          },
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
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
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

class MetaInfo extends StatelessWidget {
  final VideoInfo data;

  const MetaInfo({
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
          [
            data.provider,
            data.uploader?.maybeExtend(data.uploaderId.map((str) => " ($str)")),
            if (data.uploader == null) data.uploaderId
          ].where((element) => element != null).join(" - ").toUpperCase(),
          style: const TextStyle(fontSize: 18),
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription _incomingLinksSub;
  late final TextEditingController _textEditingController;
  late final StreamController<Deferred<VideoInfo>> _dataStreamController;

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
              return Stack(
                children: [
                  if (data.thumbnails.isNotEmpty)
                    Opacity(
                      opacity: 0.08,
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: data.thumbnails.last.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  Row(
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
                              MetaInfo(data: data),
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
                  ),
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
