import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserRepository();

  Future<UserModel> getSelf() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    final documentReference = _firebaseFirestore.doc('/users/${user.uid}');
    final snapshot = await documentReference.get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw StateError('Dados do usuário não encontrados');
    }
    return UserModel.fromJson(snapshot.data()!);
  }

  Future<UserModel> createSelf() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    final DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.doc('/users/${user.uid}');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    if (documentSnapshot.exists) {
      return UserModel.fromJson(documentSnapshot.data()!);
    } else {
      documentReference.set({
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
        'email': user.email,
      });
      return UserModel.fromJson({'email': user.email});
    }
  }

  Future<bool> getIsSuperAdmin() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }
    final DocumentReference<Map<String, dynamic>> documentReference =
        _firebaseFirestore.doc('/users/${user.uid}/private/private');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    if (documentSnapshot.exists) {
      return documentSnapshot.data()!['isSuperAdmin'] ?? false;
    }
    return false;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    final DocumentReference<Map<String, dynamic>> documentReference =
        _firebaseFirestore.doc('/users/${user.uid}');
    await documentReference.update(data);
  }
}
