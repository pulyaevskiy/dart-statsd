library statsd.tests.all;

import 'client_test.dart' as client_test;
import 'connection_test.dart' as connection_test;

void main() {
  client_test.main();
  connection_test.main();
}
