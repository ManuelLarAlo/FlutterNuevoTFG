import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('AuthService');

  Future<User?> signInWithGoogle() async {
    User? user;
    if (kIsWeb) {
      user = await _signInWithGoogleWeb();
    } else {
      user = await _signInWithGoogleMobile();
    }

    if (user != null) {
      await _createOrUpdateUserData(user);
    }
    return user;
  }

  Future<void> _createOrUpdateUserData(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    String fullName = user.displayName ?? '';
    List<String> nameParts = fullName.split(' ');

    String nombre = '';
    String apellidos = '';

    if (nameParts.isNotEmpty) {
      nombre = nameParts.first;
      if (nameParts.length > 1) {
        apellidos = nameParts.sublist(1).join(' ');
      }
    }

    if (!docSnapshot.exists) {
      await userDoc.set({
        'nombre': nombre,
        'apellidos': apellidos,
        'email': user.email ?? 'No disponible',
        'telefono': '', // Puedes dejar vacío para pedirlo luego
      });
    } else {
      await userDoc.update({
        'nombre': nombre,
        'apellidos': apellidos,
        'email': user.email ?? 'No disponible',
      });
    }
  }


  Future<User?> _signInWithGoogleWeb() async {
    try {
      // Aquí usamos el proveedor de Google para web
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      return userCredential.user;
    } catch (e, stackTrace) {
      _logger.severe('Error login web', e, stackTrace);
      return null;
    }
  }

  Future<User?> _signInWithGoogleMobile() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e, stackTrace) {
      _logger.severe('Error login web', e, stackTrace);
      return null;
    }
  }
}
