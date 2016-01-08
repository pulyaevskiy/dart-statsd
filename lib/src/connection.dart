part of statsd;

abstract class StatsdConnection {
  Future send(String packet);
  Future close();

  /// Connects to the [uri].
  static Future<StatsdConnection> connect(Uri uri) {
    if (uri.scheme != 'udp') {
      throw new ArgumentError.value(
          uri, 'host', 'Only UDP connections supported at this moment.');
    }

    return StatsdUdpConnection.bind(uri.host, uri.port);
  }
}

class StatsdUdpConnection implements StatsdConnection {
  final InternetAddress address;
  final int port;
  final RawDatagramSocket socket;

  StatsdUdpConnection._(this.address, this.port, this.socket);

  static Future<StatsdConnection> bind(String host, int port) {
    var completer = new Completer<StatsdConnection>();

    InternetAddress.lookup(host).then((_) {
      var address = _.first;
      _logger
          .fine('UDP: Internet address lookup succeeded. Using: ${address}.');
      RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, port).then((socket) {
        _logger.fine('UDP: Connected to statsd server.');
        completer.complete(new StatsdUdpConnection._(address, port, socket));
      }, onError: (e) {
        _logger.warning('UDP: Could not connect to statsd server. Error: ${e}');
        completer.complete(new StatsdUdpConnection._(address, port, null));
      });
    }, onError: (e) {
      _logger.warning('UDP: Internet address lookup succeeded. Error: ${e}.');
      completer.complete(new StatsdUdpConnection._(null, port, null));
    });

    return completer.future;
  }

  @override
  Future send(String packet) {
    _logger.fine('UDP: Sending packet to statsd: ${packet}.');
    socket?.send(packet.codeUnits, address, port);
    return new Future.value();
  }

  @override
  Future close() {
    socket?.close();
    return new Future.value();
  }
}
