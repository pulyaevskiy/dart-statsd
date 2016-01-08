part of statsd;

abstract class StatsdClient {
  Future count(String name, [int delta = 1, double sampleRate]);
  Future gauge(String name, int value);
  Future gaugeDelta(String name, int delta);
  Future set(String name, int value);
  Future time(String name, Stopwatch stopwatch, [double sampleRate]);

  factory StatsdClient(StatsdConnection connection) {
    return new _StatsdClient(connection);
  }
}

class _StatsdClient implements StatsdClient {
  final StatsdConnection connection;
  _StatsdClient(this.connection);

  @override
  Future gauge(String name, int value) {
    var packet = '${name}:${value}|g';
    return connection.send(packet);
  }

  @override
  Future gaugeDelta(String name, int delta) {
    var value = (delta < 0) ? '${delta}' : '+${delta}';
    var packet = '${name}:${value}|g';
    return connection.send(packet);
  }

  @override
  Future count(String name, [int delta = 1, double sampleRate]) {
    var packet = '${name}:${delta}|c';
    if (sampleRate is double) {
      packet += '|@${sampleRate}';
    }
    return connection.send(packet);
  }

  @override
  Future set(String name, int value) {
    var packet = '${name}:${value}|s';
    return connection.send(packet);
  }

  @override
  Future time(String name, Stopwatch stopwatch, [double sampleRate]) {
    var msec = stopwatch.elapsedMilliseconds;
    var packet = '${name}:${msec}|ms';
    if (sampleRate is double) {
      packet += '|@${sampleRate}';
    }
    return connection.send(packet);
  }
}
