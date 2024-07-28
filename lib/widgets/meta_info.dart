import 'package:flutter/material.dart';
import 'package:multistreamer/video_info.dart';
import 'package:multistreamer/utils.dart';

class MetaInfo extends StatelessWidget {
  final VideoInfo data;

  const MetaInfo({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          [
            data.provider,
            data.uploader?.maybeExtend(data.uploaderId.map((str) => " ($str)")),
            if (data.uploader == null) data.uploaderId
          ].where((element) => element != null).join(" - ").toUpperCase(),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          data.title,
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
