import 'dart:async';

import 'package:multistreamer/video_info.dart';

abstract class Fetcher {
  Future<VideoInfo> fetchVideoInfo(Uri url);

  FutureOr<void> initialize() {}

  void dispose() {}
}
