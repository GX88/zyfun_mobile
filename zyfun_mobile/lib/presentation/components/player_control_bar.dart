import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/constants.dart';
import 'buttons/app_buttons.dart';
import 'texts.dart';

class PlayerControlBar extends StatelessWidget {
  const PlayerControlBar({
    super.key,
    required this.isPlaying,
    required this.isCompleted,
    required this.isBuffering,
    required this.positionLabel,
    required this.volume,
    required this.playbackSpeed,
    required this.onTogglePlayPause,
    required this.onPlaybackSpeedChanged,
    required this.onVolumeChanged,
  });

  final bool isPlaying;
  final bool isCompleted;
  final bool isBuffering;
  final String positionLabel;
  final double volume;
  final double playbackSpeed;
  final VoidCallback onTogglePlayPause;
  final ValueChanged<double> onPlaybackSpeedChanged;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isBuffering)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: AppIconSize.sm,
                  height: AppIconSize.sm,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.sm),
                const SecondaryText('缓冲中...'),
              ],
            ),
          ),
        Row(
          children: <Widget>[
            PrimaryButton(
              onPressed: onTogglePlayPause,
              label: isPlaying ? '暂停' : isCompleted ? '重播' : '播放',
              size: AppButtonSize.small,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: SecondaryText(positionLabel)),
            SizedBox(
              width: 96,
              child: ShadSelect<double>(
                minWidth: 96,
                initialValue: playbackSpeed,
                selectedOptionBuilder: (context, value) => Text('${value}x'),
                options: const <ShadOption<double>>[
                 ShadOption(value: 0.75, child: Text('0.75x')),
                  ShadOption(value: 0.5, child: Text('0.5x')),
                  ShadOption(value: 1, child: Text('1.0x')),
                  ShadOption(value: 1.25, child: Text('1.25x')),
                  ShadOption(value: 1.5, child: Text('1.5x')),
                  ShadOption(value: 2, child: Text('2.0x')),
                  ShadOption(value: 3, child: Text('3.0x')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onPlaybackSpeedChanged(value);
                  }
                },
                placeholder: const Text('倍速'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryText('音量 ${volume.toStringAsFixed(0)}'),
        ShadSlider(
          min: 0,
          max: 100,
          initialValue: volume,
          onChanged: onVolumeChanged,
        ),
      ],
    );
  }
}
