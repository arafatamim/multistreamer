import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multistreamer/video_info.dart';
import 'package:multistreamer/utils.dart';

List<Widget> _buildSources(BuildContext context, VideoInfo data) {
  return [
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
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: item.url)).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Copied url to clipboard"),
              ),
            );
          });
        },
        onTap: () async {
          await launchIntent(
            url: item.url,
            title: data.title,
          );
        },
      ),
      const SizedBox(height: 8),
    ]
  ];
}

class SliverVideoSources extends StatelessWidget {
  final VideoInfo data;

  const SliverVideoSources({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        _buildSources(context, data),
      ),
    );
  }
}

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
      children: _buildSources(context, data),
    );
  }
}
