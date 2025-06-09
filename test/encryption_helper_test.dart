import 'package:flutter_test/flutter_test.dart';
import 'package:budget_wise/utils/encryption_helper.dart';

void main() {
  group('EncryptionHelper', () {
    const original = 'Secret123!';
    late String encrypted;

    test('encrypt should not return original', () {
      encrypted = EncryptionHelper.encrypt(original);
      expect(encrypted, isNot(equals(original)));
    });

    test('decrypt should return original', () {
      encrypted = EncryptionHelper.encrypt(original);
      final decrypted = EncryptionHelper.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('decrypting invalid base64 throws error', () {
      expect(() => EncryptionHelper.decrypt('notbase64@@'),
          throwsA(isA<FormatException>()));
    });
  });
}
