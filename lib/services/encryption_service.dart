import 'package:encrypt/encrypt.dart' as enc;
import 'dart:convert';
import 'dart:math';

class EncryptionService {
  static final _key = enc.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  static String encryptText(String plainText) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final payload = {
      'iv': base64.encode(iv.bytes),
      'cipher': encrypted.base64,
    };
    return jsonEncode(payload);
  }

  static String decryptText(String encryptedText) {
    final decoded = jsonDecode(encryptedText);
    final iv = enc.IV.fromBase64(decoded['iv']);
    final cipher = decoded['cipher'];
    final encrypter = enc.Encrypter(enc.AES(_key));
    final decrypted = encrypter.decrypt64(cipher, iv: iv);
    return decrypted;
  }

  static String safeDecrypt(String text) {
    try {
      return decryptText(text);
    } catch (e) {
      print("Dekripcija nije uspela za: $text, vraćam original");
      return text;
    }
  }
}
