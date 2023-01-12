// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$VideoFormat {
  String get url => throw _privateConstructorUsedError;
  String? get displayFormat => throw _privateConstructorUsedError;
  num? get quality => throw _privateConstructorUsedError;
  num? get width => throw _privateConstructorUsedError;
  num? get height => throw _privateConstructorUsedError;
  num? get aspectRatio => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  num? get bytes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VideoFormatCopyWith<VideoFormat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoFormatCopyWith<$Res> {
  factory $VideoFormatCopyWith(
          VideoFormat value, $Res Function(VideoFormat) then) =
      _$VideoFormatCopyWithImpl<$Res, VideoFormat>;
  @useResult
  $Res call(
      {String url,
      String? displayFormat,
      num? quality,
      num? width,
      num? height,
      num? aspectRatio,
      String? resolution,
      num? bytes});
}

/// @nodoc
class _$VideoFormatCopyWithImpl<$Res, $Val extends VideoFormat>
    implements $VideoFormatCopyWith<$Res> {
  _$VideoFormatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? displayFormat = freezed,
    Object? quality = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? aspectRatio = freezed,
    Object? resolution = freezed,
    Object? bytes = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      displayFormat: freezed == displayFormat
          ? _value.displayFormat
          : displayFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as num?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as num?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as num?,
      aspectRatio: freezed == aspectRatio
          ? _value.aspectRatio
          : aspectRatio // ignore: cast_nullable_to_non_nullable
              as num?,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      bytes: freezed == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_VideoFormatCopyWith<$Res>
    implements $VideoFormatCopyWith<$Res> {
  factory _$$_VideoFormatCopyWith(
          _$_VideoFormat value, $Res Function(_$_VideoFormat) then) =
      __$$_VideoFormatCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String? displayFormat,
      num? quality,
      num? width,
      num? height,
      num? aspectRatio,
      String? resolution,
      num? bytes});
}

/// @nodoc
class __$$_VideoFormatCopyWithImpl<$Res>
    extends _$VideoFormatCopyWithImpl<$Res, _$_VideoFormat>
    implements _$$_VideoFormatCopyWith<$Res> {
  __$$_VideoFormatCopyWithImpl(
      _$_VideoFormat _value, $Res Function(_$_VideoFormat) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? displayFormat = freezed,
    Object? quality = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? aspectRatio = freezed,
    Object? resolution = freezed,
    Object? bytes = freezed,
  }) {
    return _then(_$_VideoFormat(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      displayFormat: freezed == displayFormat
          ? _value.displayFormat
          : displayFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as num?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as num?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as num?,
      aspectRatio: freezed == aspectRatio
          ? _value.aspectRatio
          : aspectRatio // ignore: cast_nullable_to_non_nullable
              as num?,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      bytes: freezed == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc

class _$_VideoFormat implements _VideoFormat {
  const _$_VideoFormat(
      {required this.url,
      this.displayFormat,
      this.quality,
      this.width,
      this.height,
      this.aspectRatio,
      this.resolution,
      this.bytes});

  @override
  final String url;
  @override
  final String? displayFormat;
  @override
  final num? quality;
  @override
  final num? width;
  @override
  final num? height;
  @override
  final num? aspectRatio;
  @override
  final String? resolution;
  @override
  final num? bytes;

  @override
  String toString() {
    return 'VideoFormat(url: $url, displayFormat: $displayFormat, quality: $quality, width: $width, height: $height, aspectRatio: $aspectRatio, resolution: $resolution, bytes: $bytes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_VideoFormat &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.displayFormat, displayFormat) ||
                other.displayFormat == displayFormat) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.bytes, bytes) || other.bytes == bytes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, displayFormat, quality,
      width, height, aspectRatio, resolution, bytes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_VideoFormatCopyWith<_$_VideoFormat> get copyWith =>
      __$$_VideoFormatCopyWithImpl<_$_VideoFormat>(this, _$identity);
}

abstract class _VideoFormat implements VideoFormat {
  const factory _VideoFormat(
      {required final String url,
      final String? displayFormat,
      final num? quality,
      final num? width,
      final num? height,
      final num? aspectRatio,
      final String? resolution,
      final num? bytes}) = _$_VideoFormat;

  @override
  String get url;
  @override
  String? get displayFormat;
  @override
  num? get quality;
  @override
  num? get width;
  @override
  num? get height;
  @override
  num? get aspectRatio;
  @override
  String? get resolution;
  @override
  num? get bytes;
  @override
  @JsonKey(ignore: true)
  _$$_VideoFormatCopyWith<_$_VideoFormat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VideoInfo {
  String get provider => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get uploader => throw _privateConstructorUsedError;
  String? get uploaderId => throw _privateConstructorUsedError;
  String? get filename => throw _privateConstructorUsedError;
  DateTime? get uploadDate => throw _privateConstructorUsedError;
  num? get duration => throw _privateConstructorUsedError;
  List<VideoFormat> get formats => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VideoInfoCopyWith<VideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoInfoCopyWith<$Res> {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) then) =
      _$VideoInfoCopyWithImpl<$Res, VideoInfo>;
  @useResult
  $Res call(
      {String provider,
      String title,
      String? uploader,
      String? uploaderId,
      String? filename,
      DateTime? uploadDate,
      num? duration,
      List<VideoFormat> formats});
}

/// @nodoc
class _$VideoInfoCopyWithImpl<$Res, $Val extends VideoInfo>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? title = null,
    Object? uploader = freezed,
    Object? uploaderId = freezed,
    Object? filename = freezed,
    Object? uploadDate = freezed,
    Object? duration = freezed,
    Object? formats = null,
  }) {
    return _then(_value.copyWith(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uploader: freezed == uploader
          ? _value.uploader
          : uploader // ignore: cast_nullable_to_non_nullable
              as String?,
      uploaderId: freezed == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadDate: freezed == uploadDate
          ? _value.uploadDate
          : uploadDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as num?,
      formats: null == formats
          ? _value.formats
          : formats // ignore: cast_nullable_to_non_nullable
              as List<VideoFormat>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_VideoInfoCopyWith<$Res> implements $VideoInfoCopyWith<$Res> {
  factory _$$_VideoInfoCopyWith(
          _$_VideoInfo value, $Res Function(_$_VideoInfo) then) =
      __$$_VideoInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String provider,
      String title,
      String? uploader,
      String? uploaderId,
      String? filename,
      DateTime? uploadDate,
      num? duration,
      List<VideoFormat> formats});
}

/// @nodoc
class __$$_VideoInfoCopyWithImpl<$Res>
    extends _$VideoInfoCopyWithImpl<$Res, _$_VideoInfo>
    implements _$$_VideoInfoCopyWith<$Res> {
  __$$_VideoInfoCopyWithImpl(
      _$_VideoInfo _value, $Res Function(_$_VideoInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? title = null,
    Object? uploader = freezed,
    Object? uploaderId = freezed,
    Object? filename = freezed,
    Object? uploadDate = freezed,
    Object? duration = freezed,
    Object? formats = null,
  }) {
    return _then(_$_VideoInfo(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uploader: freezed == uploader
          ? _value.uploader
          : uploader // ignore: cast_nullable_to_non_nullable
              as String?,
      uploaderId: freezed == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadDate: freezed == uploadDate
          ? _value.uploadDate
          : uploadDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as num?,
      formats: null == formats
          ? _value._formats
          : formats // ignore: cast_nullable_to_non_nullable
              as List<VideoFormat>,
    ));
  }
}

/// @nodoc

class _$_VideoInfo implements _VideoInfo {
  const _$_VideoInfo(
      {required this.provider,
      required this.title,
      this.uploader,
      this.uploaderId,
      this.filename,
      this.uploadDate,
      this.duration,
      required final List<VideoFormat> formats})
      : _formats = formats;

  @override
  final String provider;
  @override
  final String title;
  @override
  final String? uploader;
  @override
  final String? uploaderId;
  @override
  final String? filename;
  @override
  final DateTime? uploadDate;
  @override
  final num? duration;
  final List<VideoFormat> _formats;
  @override
  List<VideoFormat> get formats {
    if (_formats is EqualUnmodifiableListView) return _formats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formats);
  }

  @override
  String toString() {
    return 'VideoInfo(provider: $provider, title: $title, uploader: $uploader, uploaderId: $uploaderId, filename: $filename, uploadDate: $uploadDate, duration: $duration, formats: $formats)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_VideoInfo &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.uploader, uploader) ||
                other.uploader == uploader) &&
            (identical(other.uploaderId, uploaderId) ||
                other.uploaderId == uploaderId) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.uploadDate, uploadDate) ||
                other.uploadDate == uploadDate) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._formats, _formats));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      provider,
      title,
      uploader,
      uploaderId,
      filename,
      uploadDate,
      duration,
      const DeepCollectionEquality().hash(_formats));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_VideoInfoCopyWith<_$_VideoInfo> get copyWith =>
      __$$_VideoInfoCopyWithImpl<_$_VideoInfo>(this, _$identity);
}

abstract class _VideoInfo implements VideoInfo {
  const factory _VideoInfo(
      {required final String provider,
      required final String title,
      final String? uploader,
      final String? uploaderId,
      final String? filename,
      final DateTime? uploadDate,
      final num? duration,
      required final List<VideoFormat> formats}) = _$_VideoInfo;

  @override
  String get provider;
  @override
  String get title;
  @override
  String? get uploader;
  @override
  String? get uploaderId;
  @override
  String? get filename;
  @override
  DateTime? get uploadDate;
  @override
  num? get duration;
  @override
  List<VideoFormat> get formats;
  @override
  @JsonKey(ignore: true)
  _$$_VideoInfoCopyWith<_$_VideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}
