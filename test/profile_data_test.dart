import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('Format date of birth correctly', () {
    final dob = DateTime(1995, 8, 15);
    final formatted = DateFormat.yMMMd().format(dob);

    expect(formatted, isA<String>());
    expect(formatted, contains('1995'));
  });
}
