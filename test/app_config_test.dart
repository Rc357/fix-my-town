import 'package:flutter_test/flutter_test.dart';
import 'package:obserba/app/config/app_config.dart';

void main() {
  group('AppFlavor.parse', () {
    test('parses a known flavor', () {
      expect(
        AppFlavor.parse('staging', AppFlavor.development),
        AppFlavor.staging,
      );
    });

    test('uses the fallback for an unknown flavor', () {
      expect(
        AppFlavor.parse('unknown', AppFlavor.production),
        AppFlavor.production,
      );
    });
  });
}
