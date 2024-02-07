import 'package:logger/logger.dart';

final logger = Logger(
    printer: PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 10000,
  colors: true,
  printEmojis: true,
  printTime: true,
));
