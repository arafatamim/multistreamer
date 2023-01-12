import 'dart:math' show log, pow;

extension Nullable<T> on T? {
  S? map<S>(S? Function(T) f) {
    if (this != null) {
      return f(this as T);
    } else {
      return null;
    }
  }
}

String formatSize(int bytes, [decimals = 2]) {
  const k = 1024;
  final dm = decimals < 0 ? 0 : decimals;
  const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
  final i = (log(bytes) / log(k)).floor();
  return "${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}";
}
