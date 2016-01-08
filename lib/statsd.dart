/// Statsd client library for Dart.
library statsd;

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

part 'src/client.dart';
part 'src/connection.dart';

Logger _logger = new Logger('statsd');
