import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/data/models/user_model.dart';
import 'package:vidacoletiva/data/repositories/user_repository.dart';
import 'package:vidacoletiva/data/services/login_service.dart';
import 'package:vidacoletiva/services/analytics_service.dart';

class UserController extends ChangeNotifier {
  /// Aceita o termo de consentimento e salva no backend
  Future<void> acceptTermo() async {
    if (user == null) return;
    user!.termo = true;
    await _userRepository.updateUser(user!.toJson());
    notifyListeners();
  }

  final LoginService _loginService;
  final UserRepository _userRepository = UserRepository();

  UserController(this._loginService);

  bool isLogged = false;
  bool isLoading = true;
  bool isSuperAdmin = false;

  UserModel? user;
  String? photoUrl;

  init() async {
    var ac = await _loginService.signInSilently();
    if (ac != null) {
      isLogged = true;
      try {
        await Future.wait([
          _userRepository.getSelf().then((value) => user = value),
          _userRepository
              .getIsSuperAdmin()
              .then((value) => isSuperAdmin = value)
        ]);
      } catch (e) {
        // Em caso de regra negada ou erro, segue sem admin
        isSuperAdmin = false;
      }
      getPhotoUrl();
    }
    isLoading = false;
    notifyListeners();
  }

  String getDisplayName() {
    if (FirebaseAuth.instance.currentUser == null) return "";
    return FirebaseAuth.instance.currentUser!.displayName ?? "-";
  }

  getPhotoUrl() {
    var user = FirebaseAuth.instance.currentUser!;
    for (var i = 0; i < user.providerData.length; i++) {
      var p = user.providerData[i];
      if (null != p.photoURL) {
        photoUrl = p.photoURL;
        return;
      }
    }
  }

  loginGoogle() async {
    isLoading = true;
    notifyListeners();
    var acc = await _loginService.signInWithGoogle();
    isLoading = false;
    if (acc != null) {
      try {
        await Future.wait([
          _userRepository.getSelf().then((value) => user = value),
          _userRepository
              .getIsSuperAdmin()
              .then((value) => isSuperAdmin = value)
        ]);
      } catch (e) {
        isSuperAdmin = false;
      }
      isLogged = true;
      // Log analytics event
      var firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        AnalyticsService.logUserLogin(firebaseUser.uid);
      }
    } else {
      isLogged = false;
    }
    notifyListeners();
  }

  loginApple() async {
    isLoading = true;
    notifyListeners();
    var acc = await _loginService.signInWithApple();
    isLoading = false;
    if (acc != null) {
      try {
        await Future.wait([
          _userRepository.getSelf().then((value) => user = value),
          _userRepository
              .getIsSuperAdmin()
              .then((value) => isSuperAdmin = value)
        ]);
      } catch (e) {
        isSuperAdmin = false;
      }
      isLogged = true;
      // Log analytics event
      var firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        AnalyticsService.logUserLogin(firebaseUser.uid);
      }
    } else {
      isLogged = false;
    }
    notifyListeners();
  }

  logout() async {
    isLogged = false;
    // Log analytics event
    AnalyticsService.logUserLogout();
    await _loginService.signOut();
    notifyListeners();
  }

  save(Map<String, dynamic> userDelta) async {
    await _userRepository.updateUser(userDelta);
    await _userRepository.getSelf().then((value) => user = value);
    notifyListeners();
  }
}
