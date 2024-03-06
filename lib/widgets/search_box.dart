import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController? textEditingController;
  final ValueSetter<String> onSubmit;

  const SearchBox({
    super.key,
    this.textEditingController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: FocusNode(
        onKeyEvent: (node, key) {
          if (key is KeyDownEvent) {
            if (key.logicalKey == LogicalKeyboardKey.arrowDown) {
              node.nextFocus();
            }
            if (key.logicalKey == LogicalKeyboardKey.arrowUp) {
              node.previousFocus();
            }
          }
          return KeyEventResult.ignored;
        },
      ),
      controller: textEditingController,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        hintText: "Share or enter a url to play...",
      ),
      textInputAction: TextInputAction.go,
      onSubmitted: onSubmit,
    );
  }
}
