import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.userChanges();

  Future<UserCredential> signIn(String email, String pass) {
    return _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  Future<UserCredential> signUp(String email, String pass) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    final user = userCredential.user;
    if (user != null) {
      await FirestoreService.instance.createUserIfNotExists(user);
    }

    return userCredential;
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await FirestoreService.instance.createUserIfNotExists(user);
      }

      return userCredential;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }
}
