import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidacoletiva/data/models/media_model.dart';

class EventModel {
  String? id;
  String? title;
  String? text;
  DateTime? createdAt;
  String? userID;
  String? projectId;
  List<MediaModel>? mediaModelList;
  List<String>? mediaList;

  EventModel(
      {this.id,
      this.title,
      this.text,
      this.createdAt,
      this.userID,
      this.projectId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "title": title,
      "text": text,
      "created_at": createdAt,
      "user_id": userID,
      "project_id": projectId,
      if (mediaList != null) "media": mediaList,
      if (id != null) "id": id,
    };
    return json;
  }

  EventModel.fromJson(Map<String, dynamic> json) {
    id = "${json["id"]}";
    title = json["title"];
    text = json["text"];
    createdAt = DateTime.parse(json["created_at"]);
    userID = json["user_email"];
    projectId = "${json["project_id"]}";
    if (json["media"] != null) {
      List<MediaModel> l = [];
      for (var m in json["media"]) {
        l.add(MediaModel.fromJson(this, m));
      }
      mediaModelList = l;
    }
  }

  EventModel.fromQueryDocSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> qds) {
    id = qds.id;
    Map data = qds.data();
    title = data['title'];
    text = data['text'];
    createdAt = (data["created_at"] as Timestamp).toDate();
    userID = data["user_id"];
    projectId = "${data["project_id"]}";
    if (data["media"] != null) {
      List<MediaModel> l = [];
      mediaList = [];
      for (var m in data["media"]) {
        l.add(MediaModel.fromFirebase(this, m));

        mediaList!.add(m);
      }
      mediaModelList = l;
    }
  }

  get description => null;
}
