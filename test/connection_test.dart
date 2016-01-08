library statsd.tests.connection;

import 'package:test/test.dart';
import 'package:statsd/statsd.dart';
import 'dart:io';
import 'dart:async';

void main() {
  group('StatsdConnection:', () {
    test('it creates UDP connections from Uri', () async {
      var connection =
          await StatsdConnection.connect(Uri.parse('udp://127.0.0.1:4545'));
      expect(connection, new isInstanceOf<StatsdUdpConnection>());
      connection.close();
    });

    test('it only supports UDP connections', () {
      expect(() {
        return StatsdConnection.connect(Uri.parse('tcp://127.0.0.1:4545'));
      }, throwsArgumentError);
    });
  });

  group('StatsdUdpConnection:', () {
    RawDatagramSocket server;
    StreamSubscription subscription;
    List<String> data;

    setUp(() async {
      data = new List();
      server = await RawDatagramSocket.bind('127.0.0.1', 4545);
      subscription = server.listen((RawSocketEvent e) async {
        Datagram d = server.receive();
        if (d == null) return;

        String message = new String.fromCharCodes(d.data);
        data.add(message);
        await server.close();
      });
    });

    tearDown(() {
      server.close();
    });

    test('it sends packets', () async {
      StatsdUdpConnection connection =
          await StatsdUdpConnection.bind('127.0.0.1', 4545);
      expect(connection, new isInstanceOf<StatsdUdpConnection>());
      await connection.send('test');
      await subscription.asFuture();

      expect(data, hasLength(1));
      expect(data.first, equals('test'));
      connection.close();
    });

    test('it silently ignores connection errors', () async {
      // No exceptions should be thrown.
      // TODO: how to make this test closer to real life?
      StatsdUdpConnection connection =
          await StatsdUdpConnection.bind('127.0.0.1', 4546);
      expect(connection, new isInstanceOf<StatsdUdpConnection>());
      expect(connection.socket, isNotNull);
      connection.send('test');
      connection.close();
    });

    test('it silently ignores errors of address lookup', () async {
      // No exceptions should be thrown.
      StatsdUdpConnection connection =
          await StatsdUdpConnection.bind('can.not.be.resolved', 4546);
      expect(connection, new isInstanceOf<StatsdUdpConnection>());
      expect(connection.socket, isNull);
      expect(connection.address, isNull);
      connection.send('test');
      connection.close();
    });
  });
}
