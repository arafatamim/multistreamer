import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/fetcher/fetcher.dart';
import 'package:multistreamer/fetcher/youtube_dl.dart';
import 'package:multistreamer/preferred_video_resolution.dart';
import 'package:multistreamer/utils.dart';
import 'package:multistreamer/video_info.dart';
import 'package:multistreamer/widgets/header.dart';
import 'package:multistreamer/widgets/meta_info.dart';
import 'package:multistreamer/widgets/video_sources.dart';

class LandscapeLayout extends StatelessWidget {
  final ValueSetter<String> onSubmit;
  final TextEditingController? controller;
  final Widget child;

  const LandscapeLayout({
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

class ErrorPanel extends StatelessWidget {
  final Object error;

  const ErrorPanel({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: SingleChildScrollView(
                child: SelectableText(
                  "$error",
                  style: const TextStyle(
                    fontFamily: "monospace",
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                )
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.error),
      label: const Text("An error occurred while fetching media"),
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
  late final AppLinks _appLinks;

  late final StreamSubscription<Uri> _incomingLinksSub;
  late final TextEditingController _textEditingController;
  late final StreamController<Deferred<VideoInfo>> _dataStreamController;
  late final Stream<Deferred<VideoInfo>> _broadcastStream;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();

    final initialUrl = widget.initialUrl;

    _textEditingController = TextEditingController(
      text: initialUrl?.toString(),
    );
    _dataStreamController = StreamController();
    _broadcastStream = _dataStreamController.stream.asBroadcastStream();

    if (initialUrl != null) {
      _dataStreamController.add(const InProgress());
      _fetchVideoInfo(initialUrl);
    } else {
      _dataStreamController.add(const Idle());
    }

    if (Platform.isAndroid) {
      _incomingLinksSub = _appLinks.uriLinkStream.listen(
        (link) {
          ScaffoldMessenger.of(context).clearSnackBars();

          _dataStreamController.add(const InProgress());
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

  void _launchPlayer(
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
            final normalized = approximateResolution(
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
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
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            sliver: StreamBuilder<Deferred<VideoInfo>>(
              initialData: const Idle(),
              stream: _broadcastStream,
              builder: (context, snapshot) {
                final data = snapshot.data as Deferred<VideoInfo>;
                switch (data) {
                  case Success(result: final data):
                    {
                      if (automaticLaunch) {
                        _launchPlayer(data, preferredVideoResolution);
                      }
                      return SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Header(
                              onSubmit: _setUrl,
                              textEditingController: _textEditingController,
                              settingsButton: false,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: MetaInfo(data: data),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverVideoSources(data: data),
                        ],
                      );
                    }
                  case Error(error: final err):
                    {
                      return SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Header(
                              onSubmit: _setUrl,
                              textEditingController: _textEditingController,
                              settingsButton: false,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(
                            child: ErrorPanel(error: err),
                          ),
                        ],
                      );
                    }
                  case InProgress():
                    return const SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  case Idle():
                    return SliverToBoxAdapter(
                      child: Header(
                        onSubmit: _setUrl,
                        textEditingController: _textEditingController,
                        settingsButton: false,
                      ),
                    );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    bool automaticLaunch,
    PreferredVideoResolution preferredVideoResolution,
  ) {
    return Scaffold(
      body: StreamBuilder<Deferred<VideoInfo>>(
        initialData: const Idle(),
        stream: _broadcastStream,
        builder: (context, snapshot) {
          final data = snapshot.data as Deferred<VideoInfo>;
          switch (data) {
            case Success(result: final data):
              {
                if (automaticLaunch) {
                  _launchPlayer(data, preferredVideoResolution);
                }

                return Stack(
                  children: [
                    if (data.thumbnails.isNotEmpty)
                      Opacity(
                        opacity: 0.20,
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
              }
            case Error(error: final err):
              {
                return LandscapeLayout(
                  controller: _textEditingController,
                  onSubmit: _setUrl,
                  child: Center(
                    child: ErrorPanel(error: err),
                  ),
                );
              }
            case InProgress():
              return LandscapeLayout(
                onSubmit: _setUrl,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case Idle():
              return LandscapeLayout(
                controller: _textEditingController,
                onSubmit: _setUrl,
                child: Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              );
          }
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

      _dataStreamController.add(Success(videoInfo));
    } catch (e, stack) {
      _dataStreamController.add(Error(e, stack));
    }
  }

  void _setUrl(String value) {
    try {
      final url = Uri.parse(value);
      _dataStreamController.add(const InProgress());
      _fetchVideoInfo(url);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not a valid URL!"),
        ),
      );
    }
  }
}
