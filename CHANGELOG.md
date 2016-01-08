# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.1.1]

- added logger (name 'statsd') as well as some logging for UDP connection.
- added possibility to set prefix for metric names in StatsdClient.
- fixed bug in UDP connection when it was binding to the same port as Statsd
  server.

## [0.1.0]

- initial version
