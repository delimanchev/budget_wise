import 'package:flutter_test/flutter_test.dart';

bool isValidDescription(String? text) {
  return text != null && text.trim().isNotEmpty && text.length >= 3;
}

void main() {
  test('Check for valid expense description', () {
    expect(isValidDescription('Lunch'), true);
    expect(isValidDescription(''), false);
    expect(isValidDescription('  '), false);
    expect(isValidDescription('Hi'), false); // too short
  });
}
