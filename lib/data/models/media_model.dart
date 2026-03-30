import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidacoletiva/data/models/project_model.dart';

import 'event_model.dart';

enum MediaDataType {
  png,
  jpeg,
  gif,
  mp3,
  mp4,
}

class CreateMedia {
  File? file;
  XFile? imagePickerfile;
  String mimeType;
  late String fileName;
  bool get isPickedFile {
    return imagePickerfile != null;
  }

  CreateMedia(this.file, this.mimeType) {
    fileName = file!.path.split('/').last;
  }
  CreateMedia.fromXFile(this.imagePickerfile, this.mimeType) {
    fileName = imagePickerfile!.name;
  }
}

class MediaModel {
  EventModel event;
  ProjectModel? project;
  String? name;
  String? userID;
  MediaDataType? dataType;
  Future<String>? url;

  MediaModel.fromJson(this.event, Map<String, dynamic> json) {
    // counter = json["counter"];
    switch (json["data_type"]) {
      case "P":
        dataType = MediaDataType.png;
        break;
      case "J":
        dataType = MediaDataType.jpeg;
        break;
      case "G":
        dataType = MediaDataType.gif;
        break;
      case "3":
        dataType = MediaDataType.mp3;
        break;
      case "4":
        dataType = MediaDataType.mp4;
        break;
      default:
    }
  }

  MediaModel.fromFirebase(this.event, String name) {
    List n = name.split('.');
    this.name = name;
    userID = event.userID;
    dataType = dataTypeFromMime(n[1]);
  }

  static MediaDataType dataTypeFromMime(String mime) {
    switch (mime) {
      case "png":
        return MediaDataType.png;
      case "jpeg":
      case "jpg":
        return MediaDataType.jpeg;
      case "gif":
        return MediaDataType.gif;
      case "mp3":
        return MediaDataType.mp3;
      case "mp4":
        return MediaDataType.mp4;
      default:
        return MediaDataType.png;
    }
  }

  Future<String> getUrl() async {
    if (url != null) {
      return url!;
    }
    if (FirebaseAuth.instance.currentUser == null || userID == null) {
      return Future.value('');
    }
    url = FirebaseStorage.instance
        .ref('$userID/${event.id}/$name')
        .getDownloadURL();
    return url!;
  }

  Future<Uint8List?> getBytes() {
    if (FirebaseAuth.instance.currentUser == null || userID == null) {
      return Future.value(null);
    }
    return FirebaseStorage.instance.ref('$userID/${event.id}/$name').getData();
  }
}

class ProjectMediaModel {
  ProjectModel project;
  String? name;
  String? userID;
  MediaDataType? dataType;
  Future<String>? url;

  ProjectMediaModel.fromJson(this.project, Map<String, dynamic> json) {
    // counter = json["counter"];
    switch (json["data_type"]) {
      case "P":
        dataType = MediaDataType.png;
        break;
      case "J":
        dataType = MediaDataType.jpeg;
        break;
      case "G":
        dataType = MediaDataType.gif;
        break;
      case "3":
        dataType = MediaDataType.mp3;
        break;
      case "4":
        dataType = MediaDataType.mp4;
        break;
      default:
    }
  }

  ProjectMediaModel.fromFirebase(this.project, String name) {
    List n = name.split('.');
    this.name = name;
    userID = project.ownerId;
    dataType = MediaModel.dataTypeFromMime(n[1]);
  }

  Future<String> getUrl() async {
    if (url != null) {
      return url!;
    }
    if (FirebaseAuth.instance.currentUser == null || userID == null) {
      return Future.value('');
    }
    url = FirebaseStorage.instance
        .ref('$userID/${project.id}/$name')
        .getDownloadURL();
    return url!;
  }

  Future<Uint8List?> getBytes() {
    if (FirebaseAuth.instance.currentUser == null || userID == null) {
      return Future.value(null);
    }
    return FirebaseStorage.instance
        .ref('$userID/${project.id}/$name')
        .getData();
  }
}
