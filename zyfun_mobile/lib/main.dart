import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app/app.dart';
import 'config/logger_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // 初始化日志
  await LoggerConfig.init();
  
  runApp(
    const ProviderScope(
      child: ZyfunApp(),
    ),
  );
}
