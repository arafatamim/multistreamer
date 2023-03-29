import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 2)
enum PreferredVideoResolution {
  @HiveField(0)
  p360,
  @HiveField(1)
  p480,
  @HiveField(2)
  p720,
  @HiveField(3)
  p1080,
  @HiveField(4)
  p1440,
  @HiveField(5)
  p2160,
  @HiveField(6)
  maximum
}

extension PreferredVideoResolutionExtension on PreferredVideoResolution {
  String get label {
    switch (this) {
      case PreferredVideoResolution.p360:
        return "360P";
      case PreferredVideoResolution.p480:
        return "480P";
      case PreferredVideoResolution.p720:
        return "720P";
      case PreferredVideoResolution.p1080:
        return "1080P";
      case PreferredVideoResolution.p1440:
        return "1440P";
      case PreferredVideoResolution.p2160:
        return "2160P";
      case PreferredVideoResolution.maximum:
        return "Maximum quality";
    }
  }
}

class PreferredVideoResolutionAdapter
    extends TypeAdapter<PreferredVideoResolution> {
  @override
  int get typeId => 2;

  @override
  PreferredVideoResolution read(BinaryReader reader) {
    switch (reader.read()) {
      case "p360":
        return PreferredVideoResolution.p360;
      case "p480":
        return PreferredVideoResolution.p480;
      case "p720":
        return PreferredVideoResolution.p720;
      case "p1080":
        return PreferredVideoResolution.p1080;
      case "p1440":
        return PreferredVideoResolution.p1440;
      case "p2160":
        return PreferredVideoResolution.p2160;
      case "maximum":
        return PreferredVideoResolution.maximum;
      default:
        throw Exception("invalid key");
    }
  }

  @override
  void write(BinaryWriter writer, PreferredVideoResolution obj) {
    writer.write(obj.name);
  }
}
