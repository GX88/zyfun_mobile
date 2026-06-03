import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isBuffering)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('缓冲中...', style: theme.textTheme.small),
              ],
            ),
          ),
        Row(
          children: <Widget>[
            ShadButton(
              onPressed: onTogglePlayPause,
              child: Text(isPlaying ? '暂停' : isCompleted ? '重播' : '播放'),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(positionLabel, style: theme.textTheme.small)),
            SizedBox(
              width: 96,
              child: ShadSelect<double>(
                minWidth: 96,
                initialValue: playbackSpeed,
                selectedOptionBuilder: (context, value) => Text('${value}x'),
                options: const <ShadOption<double>>[
                  ShadOption(value: 0.75, child: Text('0.75x')),
                  ShadOption(value: 1, child: Text('1.0x')),
                  ShadOption(value: 1.25, child: Text('1.25x')),
                  ShadOption(value: 1.5, child: Text('1.5x')),
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
        const SizedBox(height: 12),
        Text('音量 ${volume.toStringAsFixed(2)}', style: theme.textTheme.small),
        ShadSlider(
          min: 0,
          max: 1,
          initialValue: volume,
          onChanged: onVolumeChanged,
        ),
      ],
    );
  }
}
