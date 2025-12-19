import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/project_controller.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/data/models/project_model.dart';
import 'package:vidacoletiva/resources/assets/colour_pallete.dart';
import 'package:vidacoletiva/resources/widgets/custom_buttons.dart';
import 'package:vidacoletiva/views/home/carousel_card.dart';
import 'package:vidacoletiva/views/home/projects_carousel.dart';

class Home2Page extends StatefulWidget {
  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    UserController userController = Provider.of<UserController>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          imageCarousel(context),
          const Divider(
            height: 2,
          ),
          if (userController.isSuperAdmin)
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 50),
              child: addButton(context, () async {
                // Open add project page and wait for the created project to be returned
                final result =
                    await Navigator.pushNamed(context, '/add_project');
                if (result != null && result is ProjectModel) {
                  final ProjectController projectController =
                      Provider.of<ProjectController>(context, listen: false);
                  // Insert the new project at the beginning of the list and update UI
                  projectController.addLocalProject(result);
                }
              }, 'Adicionar Projeto', AppColors.primaryOrange),
            ),
          recentProjects(context),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 50),
            child: myProjectContributions(),
          ),
        ],
      ),
    );
  }

  Widget imageCarousel(BuildContext context) {
    final ProjectController projectsController =
        Provider.of<ProjectController>(context);
    List<Widget> carouselImages = [];

    for (int i = 0; i < projectsController.projects.length; i++) {
      carouselImages.add(
        carouselImage(context, projectsController.projects[i], i),
      );
    }

    return CarouselSlider(
        options: CarouselOptions(
            height: 200,
            viewportFraction: 0.8,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            clipBehavior: Clip.hardEdge,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            }),
        items: carouselImages);
  }

  Widget carouselImage(BuildContext context, ProjectModel project, int index) {
    return GestureDetector(
      onTap: () {
        final ProjectController projectController =
            Provider.of<ProjectController>(context, listen: false);
        projectController.selectedProject(project);
        Navigator.pushNamed(context, '/project');
      },
      child: CarouselCard(
        imageUrl: project.media != null ? project.mediaModel?.getUrl() : null,
        title: project.name ?? 'Projeto',
        heroTag: project.id ?? project.name ?? 'Projeto',
        enableHero: index == _currentIndex,
      ),
    );
  }

  Widget recentProjects(BuildContext context) {
    final ProjectController projectsController =
        Provider.of<ProjectController>(context);
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('Projetos Recentes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            )),
        ProjectsCarousel(
          cardColor: AppColors.secondaryOrange,
          projectModel: projectsController.projects,
        ),
      ],
    );
  }

  Widget myProjectContributions() {
    return const SizedBox();
  }
}
