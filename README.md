# StatsD client for Dart

[![Build Status](https://img.shields.io/travis-ci/pulyaevskiy/dart-statsd.svg?branch=master&style=flat-square)](https://travis-ci.org/pulyaevskiy/dart-statsd)
[![Coverage Status](https://img.shields.io/coveralls/pulyaevskiy/dart-statsd.svg?branch=master&style=flat-square)](https://coveralls.io/github/pulyaevskiy/dart-statsd?branch=master)
[![Pub package](https://img.shields.io/pub/v/statsd.svg?style=flat-square)](https://pub.dartlang.org/packages/statsd)
[![License](https://img.shields.io/badge/license-BSD--2-blue.svg?style=flat-square)](https://raw.githubusercontent.com/pulyaevskiy/dart-statsd/master/LICENSE)

A [StatsD](https://github.com/etsy/statsd) client library implemented in Dart.

## Installation

Use git dependency in your `pubspec.yaml`:

```yaml
dependencies:
  statsd: "^0.1.1"
```

And then import it as usual:

```dart
import 'package:statsd/statsd.dart';
```

## Usage

Basic example:

```dart
import 'dart:io';
import 'dart:async';
import 'package:statsd/statsd.dart';

Future main() async {
  var connection = await StatsdConnection.connect(
    Uri.parse('udp://127.0.0.1:5678'));
  var client = new StatsdClient(connection, prefix: 'myapp');
  // Sending counters:
  await client.count('metric1'); // increment `myapp.metric1` by 1
  await client.count('metric1', -1); // decrement `myapp.metric1` by 1
  await client.count('metric1', 5, 0.1); // increment `myapp.metric1` by 5 with 0.1 sample rate

  // Sending timings:
  var stopwatch = new Stopwatch();
  stopwatch.start();
  // client will use value of stopwatch.elapsedMilliseconds
  await client.time('response-time', stopwatch);

  // Sending gauges:
  await client.gauge('metric2', 428); // sets gauge value to 428
  await client.gaugeDelta('metric2', 3); // increments value by 3
  await client.gaugeDelta('metric2', -10); // decrements value by 10

  // Sending sets:
  await client.set('uniques', 345);

  // Sending multiple metrics at once:
  var batch = client.batch();
  batch
    ..time('response-time', stopwatch)
    ..count('total-requests', 3)
    ..set('metric1', 56);
  await batch.send();

  // Make sure to close the connection when done:
  connection.close();
}
```

Current limitations:

* Only UDP connections are supported at this moment.

## License

BSD-2
