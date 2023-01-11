import 'package:multistreamer/video_info.dart';

abstract class Fetcher {
  Future<VideoInfo> fetchVideoInfo(Uri url);
}
