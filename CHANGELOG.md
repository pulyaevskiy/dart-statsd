## [0.2.1]

- added `timeDuration` api, it's roughly the same as `time` but accepts a `Duration` type

## [0.2.0]

- updated for Dart 2

## [0.1.1]

- added logger (name 'statsd') as well as some logging for UDP connection.
- added possibility to set prefix for metric names in StatsdClient.
- fixed bug in UDP connection when it was binding to the same port as Statsd
  server.

## [0.1.0]

- initial version
