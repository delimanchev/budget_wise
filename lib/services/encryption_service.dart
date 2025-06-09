import 'package:encrypt/encrypt.dart' as enc;
import 'dart:convert';

class EncryptionService {
  static final _key =
      enc.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 znaka
  static final _iv = enc.IV.fromLength(
      16); // fiksni IV za jednostavnost; za bolju sigurnost koristi random IV

  static String encryptText(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
