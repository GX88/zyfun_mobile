import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/services/player_platform_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zyfun_mobile/player');
  final log = <String>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      log.add(call.method);
      switch (call.method) {
        case 'isPipSupported':
          return true;
        case 'enterPip':
          return true;
        default:
          return false;
      }
    });
  });

  tearDown(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('PlayerPlatformBridge 会调用画中画通道', () async {
    const bridge = PlayerPlatformBridge(channel: channel);

    expect(await bridge.isPictureInPictureSupported(), isTrue);
    expect(await bridge.enterPictureInPicture(), isTrue);
    expect(log, <String>['isPipSupported', 'enterPip']);
  });
}
