import 'package:flutter/material.dart';
import 'package:multistreamer/widgets/search_box.dart';

class Header extends StatelessWidget {
  final TextEditingController? textEditingController;
  final ValueSetter<String> onSubmit;
  final bool settingsButton;

  const Header({
    super.key,
    this.textEditingController,
    this.settingsButton = true,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBox(
            onSubmit: onSubmit,
            textEditingController: textEditingController,
          ),
        ),
        if (settingsButton) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/settings");
              Navigator.of(context).pushNamed("/settings");
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ],
    );
  }
}
