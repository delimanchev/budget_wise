import 'dart:convert';

class EncryptionHelper {
  // Simulacija enkripcije koristeći Base64 (nije prava enkripcija za produkciju!)
  static String encrypt(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  static String decrypt(String encoded) {
    final bytes = base64.decode(encoded);
    return utf8.decode(bytes);
  }
}
