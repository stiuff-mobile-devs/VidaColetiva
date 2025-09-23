import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidacoletiva/data/models/event_model.dart';

class UserModel {
  String? id;
  String? email;
  String? gender;
  String? race;
  String? occupation;
  int? county;
  String? state;
  String? countyName;
  DateTime? bornAt;
  late bool isAdmin;
  List<EventModel>? events;
  List<String>? acceptedEulas;
  bool termo = false;


  UserModel();

  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    gender = json['gender'];
    race = json['race'];
    occupation = json['occupation'];
    county = json['county'];
    state = json['state'];
    isAdmin = json['is_admin'] ?? false;
    if (json['born_at'] != null) {
      if (json['born_at'] is Timestamp) {
        bornAt = (json['born_at'] as Timestamp).toDate();
      } else if (json['born_at'] is String) {
        bornAt = DateTime.tryParse(json['born_at']);
      } else if (json['born_at'] is DateTime) {
        bornAt = json['born_at'];
      } else {
        bornAt = null;
      }
    }
    countyName = json['county_name'];
    acceptedEulas = json['accepted_eulas'];
    termo = json['termo'] ?? false;
  }

  UserModel.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
    var json = queryDocumentSnapshot.data();

    id = queryDocumentSnapshot.id;
    email = json['email'];
    gender = json['gender'];
    race = json['race'];
    occupation = json['occupation'];
    county = json['county'];
    state = json['state'];
    isAdmin = json['is_admin'] ?? false;
    if (json['born_at'] != null) {
      if (json['born_at'] is Timestamp) {
        bornAt = (json['born_at'] as Timestamp).toDate();
      } else if (json['born_at'] is String) {
        bornAt = DateTime.tryParse(json['born_at']);
      } else if (json['born_at'] is DateTime) {
        bornAt = json['born_at'];
      } else {
        bornAt = null;
      }
    }
    acceptedEulas = json['accepted_eulas'];
    termo = json['termo'] ?? false;
  }

  toJson() {
    Map<String, dynamic> json = {
      "email": email,
      "race": race,
      "occupation": occupation,
      "state": state,
      "county": county,
      "gender": gender,
      "born_at": bornAt.toString(),
      "termo": termo,
    };
    return json;
  }

  @override
  String toString() {
    return "User(email: $email, gender: $gender)";
  }
}
