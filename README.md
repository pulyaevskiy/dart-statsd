# `statsd` client for Dart

A [statsd](https://github.com/etsy/statsd) client library implemented in Dart.

## Installation

Use git dependency in your `pubspec.yaml`:

```yaml
dependencies:
  statsd:
    git: https://github.com/pulyaevskiy/dart-statsd.git
```

And then import it as usual:

```dart
import 'package:statsd/statsd.dart';
```

## Usage

> Important note: The client is designed to silently ignore any exceptions
> that may occur when sending metrics to statsd. This is done to prevent any
> interference with normal application flow.

Basic example:

```dart
import 'package:statsd/statsd.dart';


Future main() async {
  var connection = await StatsdConnection.connect(
    Uri.parse('udp://127.0.0.1:5678'));
  var client = new StatsdClient(connection);
  // Sending counters:
  await client.count('metric1'); // increment `metric1` by 1
  await client.count('metric1', -1); // decrement `metric1` by 1
  await client.count('metric1', 5, 0.1); // increment `metric1` by 5 with 0.1 sample rate

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
}
```

Current limitations:

* Only UDP connections are supported at this moment.
* Batch operations are not implemented.

## License

BSD-2
