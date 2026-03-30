import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_model.dart';

class ProjectModel {
  String? id;
  String? name;
  String? description;
  String? institution;
  String? target;
  bool? isOpen;
  List managers = [];
  List banned = [];
  ProjectMediaModel? mediaModel;
  String? media;
  String? ownerId;
  DateTime? createdAt;

  ProjectModel(
      {this.id,
      this.name,
      this.description,
      this.institution,
      this.target,
      this.isOpen});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    institution = json['institution'];
    target = json['target'];
    managers = json['managers'];
    isOpen = json['is_open'];
    ownerId = json['owner_id'];
    if (json["media"] != null) {
      mediaModel = ProjectMediaModel.fromJson(this, json["media"]);
    }
  }

  toJson() {
    Map<String, dynamic> json = {
      "name": name,
      "description": description,
      "institution": institution,
      "target": target,
      "managers": managers,
      "banned": banned,
      "is_open": isOpen,
      "owner_id": ownerId,
      if (media != null) "media": media,
    };
    return json;
  }

  ProjectModel.fromQueryDocSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
    id = queryDocumentSnapshot.id;
    Map data = queryDocumentSnapshot.data();
    name = data["name"];
    description = data["description"];
    institution = data["institution"];
    target = data["target"];
    managers = data["managers"];
    isOpen = data["is_open"];
    banned = data["banned"] ?? [];
    ownerId = data["owner_id"];
    if (data["media"] != null) {
      media = data["media"];
      mediaModel = ProjectMediaModel.fromFirebase(this, data["media"]);
    }
  }

  ProjectModel.fromDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    id = documentSnapshot.id;
    Map? data = documentSnapshot.data()!;
    name = data["name"];
    description = data["description"];
    institution = data["institution"];
    target = data["target"];
    managers = data["managers"];
    isOpen = data["is_open"];
    banned = data["banned"] ?? [];
  }
}
