class StopwatchMock implements Stopwatch {
  final int _ms;

  StopwatchMock(this._ms);

  @override
  Duration get elapsed => Duration(milliseconds: _ms);

  @override
  int get elapsedMicroseconds => elapsed.inMicroseconds;

  @override
  int get elapsedMilliseconds => elapsed.inMilliseconds;

  @override
  int get elapsedTicks => throw UnimplementedError();

  @override
  int get frequency => throw UnimplementedError();

  @override
  bool get isRunning => throw UnimplementedError();

  @override
  void reset() {}

  @override
  void start() {}

  @override
  void stop() {}
}
