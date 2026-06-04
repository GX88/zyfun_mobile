import 'package:flutter/material.dart';

import '../providers/danmaku_provider.dart';

class PlayerDanmakuOverlay extends StatelessWidget {
  const PlayerDanmakuOverlay({
    super.key,
    required this.enabled,
    required this.position,
    required this.items,
  });

  final bool enabled;
  final Duration position;
  final List<DanmakuItem> items;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final activeItems = items
        .where(
          (item) => position >= item.time && position <= item.time + const Duration(seconds: 4),
        )
        .take(3)
        .toList(growable: false);

    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final item in activeItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(item.colorHex),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
