import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_info.freezed.dart';

@freezed
class VideoFormat with _$VideoFormat {
  const factory VideoFormat({
    required String url,
    String? displayFormat,
    int? quality,
    num? width,
    num? height,
    num? aspectRatio,
    String? resolution,
    int? bytes,
  }) = _VideoFormat;
}

@freezed
class VideoInfo with _$VideoInfo {
  const factory VideoInfo({
    required String provider,
    required String title,
    String? uploader,
    String? uploaderId,
    String? filename,
    DateTime? uploadDate,
    int? duration,
    required List<VideoFormat> formats,
  }) = _VideoInfo;
}
