part of statsd;

/// Statsd client providing interface to communicate with statsd server.
abstract class StatsdClient {
  /// Sends counter metric specified by [name].
  ///
  /// By default will increment the value by `1` but you can pass any value in
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

  /// Sends timing metric from a Duration type value to the server.
  ///
  /// The client will use `Duration.inMilliseconds` as a value to send.
  ///
  /// The [sampleRate] parameter if provided tells statsd that this
  /// counter is being sampled. For instance, value `0.1` means that the counter
  /// is sampled every 1/10th of the time.
  Future timeDuration(String name, Duration duration, [double sampleRate]);

  /// Creates new batch of packets.
  ///
  /// Returned object can be used to send multiple metrics at once:
  ///
  ///     StatsdClient client = new StatsdClient(connection);
  ///     client.batch()
  ///       ..count('totals', 4)
  ///       ..set('metric2', 423)
  ///       ..send();
  StatsdBatch batch();

  /// Creates new Statsd client.
  ///
  /// If [prefix] is provided it will be prepended to all metric names that are
  /// sent via this client.
  factory StatsdClient(StatsdConnection connection, {String prefix}) {
    return new _StatsdClient(connection, prefix ?? '');
  }
}

/// Composes StatsD packet
String _packet(String prefix, String name, String value, String type,
    [double sampleRate]) {
  var rateValue = sampleRate is double ? '|@${sampleRate}' : '';
  return '${prefix}${name}:${value}|${type}${rateValue}';
}

class _StatsdClient implements StatsdClient {
  final StatsdConnection connection;
  final String prefix;
  _StatsdClient(this.connection, this.prefix);

  @override
  Future gauge(String name, int value) {
    var packet = _packet(prefix, name, value.toString(), 'g');
    return connection.send(packet);
  }

  @override
  Future gaugeDelta(String name, int delta) {
    var value = (delta < 0) ? '${delta}' : '+${delta}';
    var packet = _packet(prefix, name, value, 'g');
    return connection.send(packet);
  }

  @override
  Future count(String name, [int delta = 1, double sampleRate]) {
    var packet = _packet(prefix, name, delta.toString(), 'c', sampleRate);
    return connection.send(packet);
  }

  @override
  Future set(String name, int value) {
    var packet = _packet(prefix, name, value.toString(), 's');
    return connection.send(packet);
  }

  @override
  Future time(String name, Stopwatch stopwatch, [double sampleRate]) {
    return timeDuration(name, stopwatch.elapsed, sampleRate);
  }

  @override
  Future timeDuration(String name, Duration duration, [double sampleRate]) {
    final msec = duration.inMilliseconds.toString();
    final packet = _packet(prefix, name, msec, 'ms', sampleRate);
    return connection.send(packet);
  }

  @override
  StatsdBatch batch() => new StatsdBatch._(connection, prefix);
}

/// Batch of StatsD packets.
///
/// Usage:
///
///     StatsdClient client = new StatsdClient(connection);
///     client.batch()
///       ..count('totals', 4)
///       ..set('metric2', 423)
///       ..send();
class StatsdBatch {
  final StatsdConnection _connection;
  final String _prefix;

  List<String> _packets = new List();

  StatsdBatch._(this._connection, this._prefix);

  /// Adds counter metric specified by [name] to this batch.
  ///
  /// By default will increment the value by `1` but you can pass any value in
  /// [delta].
  ///
  /// The [sampleRate] parameter if provided tells statsd that this
  /// counter is being sampled. For instance, value `0.1` means that the counter
  /// is sampled every 1/10th of the time.
  void count(String name, [int delta = 1, double sampleRate]) {
    _packets.add(_packet(_prefix, name, delta.toString(), 'c', sampleRate));
  }

  /// Adds arbitrary value (gauge) to this batch.
  void gauge(String name, int value) {
    _packets.add(_packet(_prefix, name, value.toString(), 'g'));
  }

  /// Updates gauge specified by [name] by the value provided in [delta].
  ///
  /// The [delta] value can be negative or positive. Note:
  /// This implies you can't explicitly set a gauge to a negative number without
  /// first setting it to zero.
  void gaugeDelta(String name, int delta) {
    var value = (delta < 0) ? '${delta}' : '+${delta}';
    _packets.add(_packet(_prefix, name, value, 'g'));
  }

  /// Adds value into a Set specified by [name].
  void set(String name, int value) {
    _packets.add(_packet(_prefix, name, value.toString(), 's'));
  }

  /// Adds timing metric value to this batch.
  ///
  /// Value of `stopwatch.elapsedMilliseconds` will be used.
  ///
  /// The [sampleRate] parameter if provided tells statsd that this
  /// counter is being sampled. For instance, value `0.1` means that the counter
  /// is sampled every 1/10th of the time.
  void time(String name, Stopwatch stopwatch, [double sampleRate]) {
    var msec = stopwatch.elapsedMilliseconds.toString();
    _packets.add(_packet(_prefix, name, msec, 'ms', sampleRate));
  }

  /// Sends this batch to the server.
  Future send() {
    if (_packets.isNotEmpty) {
      var packet = _packets.join("\n");
      _packets.clear();
      return _connection.send(packet);
    } else {
      return new Future.value();
    }
  }
}
