import 'package:flutter/services.dart';

class PlayerPlatformBridge {
  const PlayerPlatformBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('zyfun_mobile/player');

  final MethodChannel _channel;

  Future<bool> isPictureInPictureSupported() async {
    final result = await _channel.invokeMethod<bool>('isPipSupported');
    return result ?? false;
  }

  Future<bool> enterPictureInPicture() async {
    final result = await _channel.invokeMethod<bool>('enterPip');
    return result ?? false;
  }
}
