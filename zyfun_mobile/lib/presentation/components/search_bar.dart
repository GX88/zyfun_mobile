import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onSubmitted,
    this.onSearch,
    this.buttonLabel,
    this.buttonEnabled = true,
    this.placeholder = '输入影片名、演员或关键词',
  });

  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onSearch;
  final String? buttonLabel;
  final bool buttonEnabled;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ShadInput(
          controller: controller,
          placeholder: Text(placeholder),
          leading: const Icon(LucideIcons.search),
          trailing: isSearching
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          onSubmitted: onSubmitted,
        ),
        if (buttonLabel != null) ...<Widget>[
          const SizedBox(height: 12),
          ShadButton(
            onPressed: buttonEnabled ? onSearch : null,
            child: Text(buttonLabel!),
          ),
        ],
      ],
    );
  }
}
