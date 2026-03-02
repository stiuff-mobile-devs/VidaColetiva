import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vidacoletiva/data/repositories/user_repository.dart';
import 'package:vidacoletiva/utils/authenticated_client.dart';

class LoginService {
  static List<String> scopes = [
    'openid',
    'email',
    'profile',
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile",
  ];
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: LoginService.scopes);
  AuthenticatedClient? authClient;
  GoogleSignInAccount? _account;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  UserRepository userRepository;
  GoogleSignInAccount? get account {
    return _account;
  }

  LoginService(this.userRepository);

  onSignIn() async {
    var b = await _account!.authentication;
    final authCredential = GoogleAuthProvider.credential(
        accessToken: b.accessToken, idToken: b.idToken);
    try {
      await firebaseAuth.signInWithCredential(authCredential);
    } catch (err) {
      debugPrint("onSignIn: $err");
    }

    authClient =
        AuthenticatedClient({"Authorization": "Bearer ${b.accessToken}"});

    userRepository.createSelf();
  }

  Future<void> onAppleSignIn(UserCredential auth) async {
    try {
      if (auth.user != null) {
        await auth.user!.reload();
        firebaseAuth = FirebaseAuth.instance;
        debugPrint("Apple sign-in processado com sucesso");
      }
    } catch (err) {
      debugPrint("onAppleSignIn: $err");
    }
    userRepository.createSelf();
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    debugPrint("Attempting Google sign-in...");
    _account = await googleSignIn.signIn();
    if (_account != null) {
      debugPrint("Google sign-in successful: ${_account!.email}");
      await onSignIn();
      return _account;
    }
    debugPrint("Google sign-in failed or cancelled.");
    return _account;
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final auth = await firebaseAuth.signInWithProvider(appleProvider);

      if (auth.user != null) {
        debugPrint("Apple sign-in successful: ${auth.user?.email}");
        await onAppleSignIn(auth);
        return auth;
      }

      debugPrint("Apple sign-in failed or cancelled.");
      return null;
    } catch (err) {
      debugPrint("Erro de Login Apple: $err");
      return null;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    if (_account != null) {
      await onSignIn();
      return _account;
    }
    _account = await googleSignIn.signInSilently();
    if (_account != null) {
      await onSignIn();
    }
    return _account;
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> requestGoogleDriveScope() async {
    return await googleSignIn.requestScopes(scopes +
        [
          'https://www.googleapis.com/auth/drive.file',
        ]);
  }
}
