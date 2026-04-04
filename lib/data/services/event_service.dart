import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/data/models/event_model.dart';
import 'package:vidacoletiva/data/models/media_model.dart';
import 'package:vidacoletiva/data/repositories/event_repository.dart';

class EventService {
  final EventRepository _eventRepository;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  EventService(this._eventRepository);

  Future<List<EventModel>> listOwn() async {
    return _eventRepository.listMyEvents();
  }

  Future<List<EventModel>> listEventsOnProject(String projectId) async {
    return _eventRepository.listAllOnProject(projectId);
  }

  Future<EventModel> addEvent(
      EventModel event, List<CreateMedia> createMediaList) async {
    if (createMediaList.isNotEmpty) {
      event.mediaList = createMediaList
          .map((e) => e.fileName == "audio" ? "audio.mp3" : e.fileName)
          .toList();
    }
    EventModel e = await _eventRepository.create(event);

    if ((e.mediaList ?? []).isNotEmpty) {
      e.mediaModelList = e.mediaList!
          .map((mediaName) => MediaModel.fromFirebase(e, mediaName))
          .toList();
    }

    if (createMediaList.isNotEmpty) {
      List<Future<TaskSnapshot>> uploadTasks = [];
      for (var media in createMediaList) {
        Reference ref = _firebaseStorage.ref(
            '/${_firebaseAuth.currentUser!.uid}/${e.id}/${media.fileName == "audio" ? "audio.mp3" : media.fileName}');
        UploadTask uploadTask;
        if (media.isPickedFile) {
          uploadTask = ref.putFile(File(media.imagePickerfile!.path));
        } else {
          uploadTask = ref.putFile(media.file!);
        }
        uploadTasks.add(uploadTask);
      }
      await Future.wait(uploadTasks)
          .then((value) => debugPrint("finalizado o upload de arquivos"));
    }

    return e;
  }
}
