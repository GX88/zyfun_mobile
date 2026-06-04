import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'buttons/app_buttons.dart';
import 'inputs/app_inputs.dart';

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
        SearchInput(
          controller: controller,
          placeholder: placeholder,
          trailing: isSearching
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: SizedBox(
                    width: AppIconSize.sm,
                    height: AppIconSize.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          onSubmitted: onSubmitted,
        ),
        if (buttonLabel != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            onPressed: buttonEnabled ? onSearch : null,
            label: buttonLabel!,
          ),
        ],
      ],
    );
  }
}
