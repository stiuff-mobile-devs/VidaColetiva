import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/event_controller.dart';
import 'package:vidacoletiva/controllers/project_controller.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/resources/widgets/main_app_bar.dart';

import '../resources/assets/colour_pallete.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  bool _isValidHttpUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }

  Widget _projectFallbackImage() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/resources/assets/images/stock-image.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProjectController projectController =
        Provider.of<ProjectController>(context);
    final UserController userController = Provider.of<UserController>(context);
    final project = projectController.project;

    return Scaffold(
      appBar: mainAppBar(context, leading: true, profile: false),
      // endDrawer: mainDrawer(context)
      floatingActionButton: addEventButton(),
      body: project == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Projeto indisponível no momento.',
                  style: TextStyle(fontSize: 18, color: AppColors.darkGreen),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  leadingImage(projectController),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        aboutText(projectController),
                        const SizedBox(
                          height: 10,
                        ),
                        if (userController.isSuperAdmin)
                          allEventButton(context, project.id),
                        const SizedBox(
                          height: 10,
                        ),
                        myContributions(),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget leadingImage(ProjectController projectController) {
    return Stack(
      children: [
        projectController.project?.media != null
            ? FutureBuilder(
                future: projectController.project?.mediaModel?.getUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final url = snapshot.data?.toString();
                  if (snapshot.hasError || !_isValidHttpUrl(url)) {
                    return _projectFallbackImage();
                  }

                  return Hero(
                    tag:
                        "${projectController.project?.id ?? projectController.project?.name ?? 'projeto'}_image",
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(url!.trim()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              )
            : _projectFallbackImage(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8),
                  child: Text(
                      projectController.project?.name ?? "Nome do projeto",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget aboutText(ProjectController projectController) {
    return Row(
      children: [
        Flexible(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sobre',
                style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5)),
            Text(
                (projectController.project?.description != null &&
                        projectController.project!.description!.isNotEmpty)
                    ? projectController.project!.description!
                    : "Não há descrição para o projeto ${projectController.project?.name}",
                style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5)),
          ]),
        ),
      ],
    );
  }

  Widget myContributions() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        side: const BorderSide(
          color: AppColors.darkGreen,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/my_contributions');
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Minhas Contribuições',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.darkGreen,
              size: 32,
            )
          ],
        ),
      ),
    );
  }

  Widget allEventButton(BuildContext context, String? projectId) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        side: const BorderSide(
          color: AppColors.darkGreen,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Provider.of<EventController>(context, listen: false)
            .listEventsOnProject(projectId ?? "");
        Navigator.pushNamed(context, '/all_events');
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Todos Relatos',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.darkGreen,
              size: 32,
            )
          ],
        ),
      ),
    );
  }

  Widget addEventButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryGreen,
      onPressed: () {
        Navigator.pushNamed(context, '/add_event');
      },
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }
}
