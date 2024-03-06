import 'package:flutter/material.dart';
import 'package:multistreamer/video_info.dart';
import 'package:multistreamer/utils.dart';

class VideoSources extends StatelessWidget {
  final VideoInfo data;

  const VideoSources({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final item in data.formats.reversed) ...[
          ListTile(
            title: Text(item.resolution ?? "Unknown resolution"),
            subtitle: Text(
              [
                item.displayFormat,
                item.bytes.map(formatSize),
              ].where((element) => element != null).join(" - "),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.black12,
            onTap: () async {
              await launchIntent(
                url: item.url,
                title: data.title,
              );
            },
          ),
          const SizedBox(height: 8)
        ]
      ],
    );
  }
}
