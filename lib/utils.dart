import 'dart:math' show log, pow;
import 'dart:typed_data';

import 'package:multistreamer/preferred_video_resolution.dart';

extension StringExtension on String {
  String maybeExtend(String? str) {
    if (str != null) {
      return this + str;
    } else {
      return this;
    }
  }
}

extension Nullable<T> on T? {
  S? map<S>(S? Function(T) f) {
    if (this != null) {
      return f(this as T);
    } else {
      return null;
    }
  }

  S mapWithDefault<S>(S Function(T) f, S defaultValue) {
    if (this != null) {
      return f(this as T);
    } else {
      return defaultValue;
    }
  }

  T orElse(T defaultValue) {
    if (this != null) {
      return this as T;
    } else {
      return defaultValue;
    }
  }
}

String formatSize(num bytes, [decimals = 2]) {
  const k = 1024;
  final dm = decimals < 0 ? 0 : decimals;
  const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
  final i = (log(bytes) / log(k)).floor();
  return "${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}";
}

PreferredVideoResolution normalizeResolution(
  num? width,
  num? height,
) {
  num smallerSide = 0;
  if (width == null && height != null) {
    smallerSide = height;
  }
  if (width != null && height == null) {
    smallerSide = width;
  }
  if (width != null && height != null) {
    if (width < height) {
      smallerSide = width;
    } else {
      smallerSide = height;
    }
  }

  const sizes = [360, 480, 720, 1080, 1440, 2160];
  final closest = findClosestNumber(smallerSide.toInt(), sizes);
  switch (closest) {
    case 360:
      return PreferredVideoResolution.p360;
    case 480:
      return PreferredVideoResolution.p480;
    case 720:
      return PreferredVideoResolution.p720;
    case 1080:
      return PreferredVideoResolution.p1080;
    case 1440:
      return PreferredVideoResolution.p1440;
    case 2160:
      return PreferredVideoResolution.p2160;
    default:
      return PreferredVideoResolution.maximum;
  }
}

int findClosestNumber(int inputNumber, List<int> numbers) {
  int closestNumber = numbers[0];
  int smallestDifference = (inputNumber - closestNumber).abs();

  for (int i = 1; i < numbers.length; i++) {
    int currentDifference = (inputNumber - numbers[i]).abs();
    if (currentDifference < smallestDifference) {
      smallestDifference = currentDifference;
      closestNumber = numbers[i];
    }
  }

  return closestNumber;
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);
