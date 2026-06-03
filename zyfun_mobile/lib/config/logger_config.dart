import 'package:logger/logger.dart';

class LoggerConfig {
  static late Logger _logger;

  static Future<void> init() async {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static Logger get logger => _logger;
}
