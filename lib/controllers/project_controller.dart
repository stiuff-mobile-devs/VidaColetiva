import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/data/models/project_model.dart';
import 'package:vidacoletiva/data/services/project_service.dart';
import 'package:vidacoletiva/services/analytics_service.dart';

import '../data/models/media_model.dart';

class ProjectController extends ChangeNotifier {
  ProjectService projectService;
  UserController? userController;
  BuildContext context;

  ProjectController(this.context, this.projectService, this.userController);

  bool _disposed = false;
  int _loadCycle = 0;
  bool? _lastIsLogged;
  bool? _lastIsAdmin;

  ProjectModel? project;
  List<ProjectModel> projects = [];

  File? selectedImage;
  CreateMedia? createMedia;
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController institutionController = TextEditingController();
  TextEditingController targetController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isOpen = false;
  GlobalKey<FormState> createProjectFormKey = GlobalKey<FormState>();

  Future<void> init() async {
    final cycle = ++_loadCycle;
    await listProjects(cycle: cycle);
  }

  void setUserController(UserController? controller) {
    userController = controller;

    final isLogged = controller?.isLogged ?? false;
    final isAdmin = controller?.isSuperAdmin ?? false;
    final loginChanged = _lastIsLogged != isLogged;
    final adminChanged = _lastIsAdmin != isAdmin;

    _lastIsLogged = isLogged;
    _lastIsAdmin = isAdmin;

    if (!isLogged) {
      final hadState = projects.isNotEmpty || project != null;
      projects = [];
      project = null;
      if (hadState) {
        _safeNotifyListeners();
      }
      return;
    }

    if (loginChanged || adminChanged || projects.isEmpty) {
      unawaited(init());
    }
  }

  Future pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    File f = File(returnedImage.path);

    selectedImage = f;
    _safeNotifyListeners();

    createMedia = CreateMedia(f, f.path.split('.').last);
  }

  Future<void> listProjects({int? cycle}) async {
    debugPrint("isAdmin: ${userController?.isSuperAdmin}");
    final fetchedProjects = await projectService.listProjects(
        isAdmin: userController?.isSuperAdmin ?? false);
    if (_disposed) return;
    if (cycle != null && cycle != _loadCycle) return;

    projects = fetchedProjects;
    debugPrint('events: ${projects.length}');
    _safeNotifyListeners();
  }

  selectedProject(ProjectModel project) {
    this.project = project;
    _safeNotifyListeners();
  }

  /// Add a project to the local list and notify listeners.
  void addLocalProject(ProjectModel p) {
    projects.insert(0, p);
    _safeNotifyListeners();
  }

  Future createProject(BuildContext context) async {
    if (createProjectFormKey.currentState == null ||
        !createProjectFormKey.currentState!.validate()) return;
    if (createMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma imagem'),
        ),
      );
      return;
    }
    String name = nameController.text;
    String institution = institutionController.text;
    String target = targetController.text;
    String description = descriptionController.text;
    bool isOpen = this.isOpen;

    isLoading = true;
    _safeNotifyListeners();

    try {
      ProjectModel p = await projectService.addProject(
          ProjectModel(
            name: name,
            institution: institution,
            description: description,
            target: target,
            isOpen: isOpen,
          ),
          createMedia);

      projects.add(p);
      _safeNotifyListeners();

      // Log analytics event
      AnalyticsService.logProjectCreation(name);

      // Show success message including project name
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Projeto "${p.name}" criado com sucesso'),
        ),
      );

      // Clear form fields and state
      nameController.clear();
      institutionController.clear();
      targetController.clear();
      descriptionController.clear();
      selectedImage = null;
      createMedia = null;
      this.isOpen = false;
      // Reset form state if possible
      try {
        createProjectFormKey.currentState?.reset();
      } catch (_) {}

      _safeNotifyListeners();

      // Close the create project page and return to previous screen
      try {
        Navigator.pop(context, p);
      } catch (_) {}
    } catch (e, s) {
      // Log technical error for debugging
      debugPrint('createProject error: $e');
      debugPrint('$s');

      // Show friendly error message to the end user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não foi possível criar o projeto. Tente novamente mais tarde.'),
        ),
      );
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  void setIsOpen(bool open) {
    isOpen = open;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
