import 'dart:convert' show jsonDecode;
import 'dart:io' show Process, Platform;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:multistreamer/utils.dart';
import 'package:flutter/services.dart';
import 'package:multistreamer/fetcher/fetcher.dart';
import 'package:multistreamer/video_info.dart';

class YouTubeDL extends Fetcher {
  final methodChannel = const MethodChannel(
    "com.arafatamim.multistreamer/youtubedl",
  );

  VideoInfo _parseJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json["title"],
      provider: json["extractor"],
      uploader: json["uploader"],
      uploaderId: json["uploader_id"],
      filename: json["filename"],
      duration: json["duration"],
      uploadDate: (json["upload_date"] as String?).map(DateTime.tryParse),
      formats: (json["formats"] as List<dynamic>?).orElse([]).map(
        (e) {
          final quality = e["quality"];
          return VideoFormat(
            url: e["url"],
            quality: quality != null
                ? (quality is num ? quality : num.tryParse(quality))
                : null,
            width: e["width"] as num?,
            height: e["height"] as num?,
            resolution: e["resolution"],
            aspectRatio: e["aspect_ratio"],
            displayFormat: e["format"],
            bytes: e["filesize"] ?? e["filesize_approx"],
          );
        },
      ).toList(),
      thumbnails: (json["thumbnails"] as List<dynamic>?)
          .orElse([])
          .map(
            (e) => VideoThumbnail(
              url: e["url"],
              width: e["width"],
              height: e["height"],
              resolution: e["resolution"],
            ),
          )
          .toList(),
    );
  }

  @override
  Future<VideoInfo> fetchVideoInfo(Uri url) async {
    final hive = Hive.box("settings");

    final legacyServerConnect = hive.get(
      "legacyServerConnect",
      defaultValue: false,
    ) as bool;

    if (Platform.isLinux) {
      final process = await Process.run(
        "yt-dlp",
        [
          "--dump-json",
          if (legacyServerConnect) "--legacy-server-connect",
          url.toString()
        ],
      );
      if (process.stdout == "" && process.stderr.trim() != "") {
        throw Exception(process.stderr);
      } else {
        final json = jsonDecode(process.stdout);
        return _parseJson(json);
      }
    } else if (Platform.isAndroid) {
      final data = await methodChannel.invokeMethod<String>(
        "dumpJson",
        {
          "url": url.toString(),
          "legacyServerConnect": legacyServerConnect,
        },
      ).then(
        (value) {
          if (value == null) {
            throw Exception("Data not received!");
          }
          return _parseJson(jsonDecode(value));
        },
      );
      return data;
    } else {
      throw UnimplementedError("Only Linux & Android supported!");
    }
  }
}
