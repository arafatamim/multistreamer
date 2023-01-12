import 'dart:math' show log, pow;

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
