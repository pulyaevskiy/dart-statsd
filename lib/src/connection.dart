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
      RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, port).then((socket) {
        completer.complete(new StatsdUdpConnection._(address, port, socket));
      },
          onError: (e) => completer
              .complete(new StatsdUdpConnection._(address, port, null)));
    },
        onError: (e) =>
            completer.complete(new StatsdUdpConnection._(null, port, null)));

    return completer.future;
  }

  @override
  Future send(String packet) {
    socket?.send(packet.codeUnits, address, port);
    return new Future.value();
  }

  @override
  Future close() {
    socket?.close();
    return new Future.value();
  }
}
