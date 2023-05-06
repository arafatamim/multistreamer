import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_links/app_links.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/fetcher/fetcher.dart';
import 'package:multistreamer/fetcher/youtube_dl.dart';
import 'package:multistreamer/preferred_video_resolution.dart';
import 'package:multistreamer/utils.dart';
import 'package:multistreamer/video_info.dart';

final appLinks = AppLinks();

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
    arguments: {
      "title": title,
    },
    arrayArguments: {
      "headers": ["referer", url],
    },
  );
  return intent.launch();
}

class LandscapeBoilerplate extends StatelessWidget {
  final ValueSetter<String> onSubmit;
  final TextEditingController? controller;
  final Widget child;

  const LandscapeBoilerplate({
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

class SearchBox extends StatelessWidget {
  final TextEditingController? textEditingController;
  final ValueSetter<String> onSubmit;

  const SearchBox({
    super.key,
    this.textEditingController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}

class Header extends StatelessWidget {
  final TextEditingController? textEditingController;
  final ValueSetter<String> onSubmit;
  final bool settingsButton;

  const Header({
    super.key,
    this.textEditingController,
    this.settingsButton = true,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBox(
            onSubmit: onSubmit,
            textEditingController: textEditingController,
          ),
        ),
        if (settingsButton)
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/settings");
            },
            icon: const Icon(Icons.settings),
          ),
      ],
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

class HomePage extends StatefulWidget {
  final String title;

  final Uri? initialUrl;
  const HomePage({super.key, required this.title, this.initialUrl});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
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
      _fetchVideoInfo(initialUrl);
    } else {
      _dataStreamController.add(const Deferred.idle());
    }

    if (Platform.isAndroid) {
      _incomingLinksSub = appLinks.uriLinkStream.listen(
        (link) {
          ScaffoldMessenger.of(context).clearSnackBars();

          _dataStreamController.add(const Deferred.inProgress());
          setState(() {
            _textEditingController.text = link.toString();
          });
          _fetchVideoInfo(link);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$error")),
          );
        },
      );
    }
  }

  void _launchStream(
    VideoInfo data,
    PreferredVideoResolution preferredResolution,
  ) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        String urlToLaunch = data.formats.first.url;
        if (preferredResolution == PreferredVideoResolution.maximum) {
          urlToLaunch = data.formats.last.url;
        } else {
          for (var format in data.formats) {
            final normalized = normalizeResolution(
              format.width,
              format.height,
            );
            if (normalized == preferredResolution) {
              urlToLaunch = format.url;
              break;
            }
          }
        }
        launchIntent(
          url: urlToLaunch,
          title: data.title,
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    bool automaticLaunch,
    PreferredVideoResolution preferredVideoResolution,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 0,
                  child: Text("Settings"),
                )
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.of(context).pushNamed("/settings");
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<Deferred<VideoInfo>>(
          initialData: const Deferred.idle(),
          stream: _dataStreamController.stream,
          builder: (context, snapshot) {
            final data = snapshot.data as Deferred<VideoInfo>;
            return data.when(
              success: (data) {
                if (automaticLaunch) {
                  _launchStream(data, preferredVideoResolution);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      onSubmit: _setUrl,
                      textEditingController: _textEditingController,
                      settingsButton: false,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: MetaInfo(data: data),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      flex: 1,
                      child: VideoSources(data: data),
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
                return Header(
                  onSubmit: _setUrl,
                  textEditingController: _textEditingController,
                  settingsButton: false,
                );
              },
              inProgress: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              idle: () {
                return Header(
                  onSubmit: _setUrl,
                  textEditingController: _textEditingController,
                  settingsButton: false,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
      bool automaticLaunch, PreferredVideoResolution preferredVideoResolution) {
    return Scaffold(
      body: StreamBuilder<Deferred<VideoInfo>>(
        initialData: const Deferred.idle(),
        stream: _dataStreamController.stream,
        builder: (context, snapshot) {
          final data = snapshot.data as Deferred<VideoInfo>;
          return data.when(
            success: (data) {
              if (automaticLaunch) {
                _launchStream(data, preferredVideoResolution);
              }

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
                      ),
                    ],
                  ),
                ],
              );
            },
            error: (err, stackTrace) {
              SchedulerBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$err"),
                      duration: const Duration(seconds: 15),
                    ),
                  );
                },
              );
              return LandscapeBoilerplate(
                controller: _textEditingController,
                onSubmit: _setUrl,
                child: const Center(
                  child: Icon(Icons.error),
                ),
              );
            },
            inProgress: () => LandscapeBoilerplate(
              controller: _textEditingController,
              onSubmit: _setUrl,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            idle: () => LandscapeBoilerplate(
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box("settings").listenable(),
        builder: (context, box, child) {
          final preferredVideoResolution = box.get(
            "preferredQuality",
            defaultValue: PreferredVideoResolution.p1080,
          ) as PreferredVideoResolution;
          final automaticLaunch = box.get(
            "automaticLaunch",
            defaultValue: false,
          );
          return OrientationBuilder(
            builder: (context, orientation) {
              switch (orientation) {
                case Orientation.portrait:
                  return _buildPortraitLayout(
                    automaticLaunch,
                    preferredVideoResolution,
                  );
                case Orientation.landscape:
                  return _buildLandscapeLayout(
                    automaticLaunch,
                    preferredVideoResolution,
                  );
              }
            },
          );
        });
  }

  @override
  void dispose() {
    _incomingLinksSub.cancel();
    _textEditingController.dispose();
    _dataStreamController.close();
    super.dispose();
  }

  void _fetchVideoInfo(Uri url) async {
    Fetcher fetcher;

    try {
      switch (url.host) {
        default:
          fetcher = YouTubeDL();
      }
      await fetcher.initialize();
      VideoInfo videoInfo = await fetcher.fetchVideoInfo(url);
      fetcher.dispose();

      _dataStreamController.add(Deferred.success(videoInfo));
    } catch (e, stack) {
      _dataStreamController.add(Deferred.error(e, stack));
    }
  }

  void _setUrl(String value) {
    try {
      final url = Uri.parse(value);
      _dataStreamController.add(const Deferred.inProgress());
      _fetchVideoInfo(url);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not a valid URL!")),
      );
    }
  }
}
