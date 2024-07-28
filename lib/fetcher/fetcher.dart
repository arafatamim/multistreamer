import 'dart:async';

import 'package:multistreamer/video_info.dart';

class FetcherMeta {
  final String name;
  final String version;

  const FetcherMeta({
    required this.name,
    required this.version,
  });
}

abstract class Fetcher {
  Future<VideoInfo> fetchVideoInfo(Uri url);

  FutureOr<void> initialize() {}

  FutureOr<FetcherMeta> getMeta();

  void dispose() {}
}
