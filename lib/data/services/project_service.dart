import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:vidacoletiva/data/models/project_model.dart';
import 'package:vidacoletiva/data/repositories/project_repository.dart';
import '../models/media_model.dart';

class ProjectService {
  final ProjectRepository _projectRepository;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ProjectService(this._projectRepository);

  Future<List<ProjectModel>> listProjects({bool isAdmin = false}) async {
    return _projectRepository.listProjects(isAdmin);
  }

  Future<ProjectModel> addProject(
      ProjectModel project, CreateMedia? createMedia) async {
    if (createMedia != null) {
      project.media = createMedia.fileName;
    }
    ProjectModel e = await _projectRepository.createProject(project);

    if (createMedia != null) {
      List<Future<TaskSnapshot>> uploadTasks = [];

      Reference ref = _firebaseStorage.ref(
          '/${_firebaseAuth.currentUser!.uid}/${e.id}/${createMedia.fileName}');
      UploadTask uploadTask;
      if (createMedia.isPickedFile) {
        uploadTask = ref.putFile(File(createMedia.imagePickerfile!.path));
      } else {
        uploadTask = ref.putFile(createMedia.file!);
      }
      uploadTasks.add(uploadTask);
      await Future.wait(uploadTasks)
          .then((value) => debugPrint("finalizado o upload de arquivos"));
      // Ensure the returned project has mediaModel populated and its URL resolved
      try {
        e.media = createMedia.fileName;
        e.mediaModel = ProjectMediaModel.fromFirebase(e, createMedia.fileName);
        // Await the URL fetch so callers receive a project with a ready mediaModel
        await e.mediaModel!.getUrl();
      } catch (ex) {
        debugPrint(
            'Warning: failed to populate mediaModel for project ${e.id}: $ex');
      }
    }

    // Ensure name is not null when possible; fallback to a safe placeholder
    if (e.name == null || e.name!.isEmpty) {
      e.name = project.name ?? 'Projeto';
    }

    return e;
  }
}
