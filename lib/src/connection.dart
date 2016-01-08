part of statsd;

/// Interface for statsd client connection implementations.
abstract class StatsdConnection {
  Future send(String packet);
  Future close();

  /// Connects to the [uri].
  ///
  /// Only UDP connections supported at this moment.
  /// Example URI: `udp://127.0.0.1:8125`
  static Future<StatsdConnection> connect(Uri uri) {
    if (uri.scheme != 'udp') {
      throw new ArgumentError.value(
          uri, 'host', 'Only UDP connections supported at this moment.');
    }

    return StatsdUdpConnection.bind(uri.host, uri.port);
  }
}

/// UDP socket client connection communitating with statsd server.
class StatsdUdpConnection implements StatsdConnection {
  final InternetAddress address;
  final int port;
  final RawDatagramSocket socket;

  StatsdUdpConnection._(this.address, this.port, this.socket);

  static Future<StatsdConnection> bind(String address, int port) {
    var completer = new Completer<StatsdConnection>();

    InternetAddress.lookup(address).then((_) {
      var address = _.first;
      _logger.info('Internet address lookup succeeded. Using: ${address}.');
      RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0).then((socket) {
        _logger.info('Connected to port ${socket.port}.');
        completer.complete(new StatsdUdpConnection._(address, port, socket));
      }, onError: (e, stackTrace) {
        _logger.warning('Error binding to a port. Error: ${e}', e, stackTrace);
        completer.complete(new StatsdUdpConnection._(address, port, null));
      });
    }, onError: (e, stackTrace) {
      _logger.warning(
          'Internet address lookup failed. Error: ${e}.', e, stackTrace);
      completer.complete(new StatsdUdpConnection._(null, port, null));
    });

    return completer.future;
  }

  @override
  Future send(String packet) {
    _logger.fine('Sending packet to statsd: ${packet}.');
    socket?.send(packet.codeUnits, address, port);
    return new Future.value();
  }

  @override
  Future close() {
    socket?.close();
    return new Future.value();
  }
}
