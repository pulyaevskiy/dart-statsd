part of statsd;

/// Statsd client providing interface to communicate with statsd server.
abstract class StatsdClient {
  /// Connection to statsd server.
  StatsdConnection get connection;

  /// Prefix for metric names. Will be prepended to all metric names sent via
  /// this client.
  String get prefix;

  /// Sends counter metric specified by [name].
  ///
  /// By default will increment the value by 1 but you can pass any value in
  /// [delta].
  ///
  /// The [sampleRate] parameter if provided tells statsd that this
  /// counter is being sampled. For instance, value `0.1` means that the counter
  /// is sampled every 1/10th of the time.
  Future count(String name, [int delta = 1, double sampleRate]);

  /// Sends arbitrary value (gauge) to the server.
  Future gauge(String name, int value);

  /// Updates gauge specified by [name] by the value provided in [delta].
  ///
  /// The [delta] value can be negative or positive. Note:
  /// This implies you can't explicitly set a gauge to a negative number without
  /// first setting it to zero.
  Future gaugeDelta(String name, int delta);

  /// Adds value into a Set specified by [name].
  Future set(String name, int value);

  /// Sends timing metric value to the server.
  ///
  /// The client will use `stopwatch.elapsedMilliseconds` as a value to send.
  ///
  /// The [sampleRate] parameter if provided tells statsd that this
  /// counter is being sampled. For instance, value `0.1` means that the counter
  /// is sampled every 1/10th of the time.
  Future time(String name, Stopwatch stopwatch, [double sampleRate]);

  /// Creates new Statsd client.
  ///
  /// If [prefix] is provided it will be prepended to all metric names that are
  /// sent via this client.
  factory StatsdClient(StatsdConnection connection, {String prefix}) {
    return new _StatsdClient(connection, prefix ?? '');
  }
}

class _StatsdClient implements StatsdClient {
  final StatsdConnection connection;
  final String prefix;
  _StatsdClient(this.connection, this.prefix);

  String compose(String name, String value, String type, [double sampleRate]) {
    var rateValue = sampleRate is double ? '|@${sampleRate}' : '';
    return '${prefix}${name}:${value}|${type}${rateValue}';
  }

  @override
  Future gauge(String name, int value) {
    var packet = compose(name, value.toString(), 'g');
    return connection.send(packet);
  }

  @override
  Future gaugeDelta(String name, int delta) {
    var value = (delta < 0) ? '${delta}' : '+${delta}';
    var packet = compose(name, value, 'g');
    return connection.send(packet);
  }

  @override
  Future count(String name, [int delta = 1, double sampleRate]) {
    var packet = compose(name, delta.toString(), 'c', sampleRate);
    return connection.send(packet);
  }

  @override
  Future set(String name, int value) {
    var packet = compose(name, value.toString(), 's');
    return connection.send(packet);
  }

  @override
  Future time(String name, Stopwatch stopwatch, [double sampleRate]) {
    var msec = stopwatch.elapsedMilliseconds.toString();
    var packet = compose(name, msec, 'ms', sampleRate);
    return connection.send(packet);
  }
}
