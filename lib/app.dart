import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/event_controller.dart';
import 'package:vidacoletiva/controllers/project_controller.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/resources/assets/colour_pallete.dart';
import 'package:vidacoletiva/views/add_event_page.dart';
import 'package:vidacoletiva/views/add_project_page.dart';
import 'package:vidacoletiva/views/admin_page.dart';
import 'package:vidacoletiva/views/admin_users_page.dart';
import 'package:vidacoletiva/views/all_events_on_project_page.dart';
import 'package:vidacoletiva/views/edit_profile_data.dart';
import 'package:vidacoletiva/views/events_page.dart';
import 'package:vidacoletiva/views/home_page.dart';
import 'package:vidacoletiva/views/my_contributions_page.dart';
import 'package:vidacoletiva/views/profile_data.dart';
import 'package:vidacoletiva/views/profile_page.dart';
import 'package:vidacoletiva/views/project_page.dart';
import 'package:vidacoletiva/views/redirection_page.dart';

class VidaColetiva extends StatelessWidget {
  const VidaColetiva({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserController>(
              create: (_) => UserController(GetIt.I.get())..init()),
          ChangeNotifierProvider<EventController>(
              create: (_) => EventController(GetIt.I.get())..init()),
          ChangeNotifierProxyProvider<UserController, ProjectController>(
            create: (_) => ProjectController(_, GetIt.I.get(), null),
            update: (_, userController, __) =>
                ProjectController(_, GetIt.I.get(), userController)..init(),
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Vida Coletiva',
            theme: ThemeData(
              primaryColor: AppColors.primaryOrange,
              textTheme: TextTheme(
                bodyLarge: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 16,
                ),
                bodyMedium: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 14,
                ),
                bodySmall: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 12,
                ),
                titleLarge: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 20,
                ),
                titleMedium: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 18,
                ),
                titleSmall: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 16,
                ),
                labelLarge: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 16,
                ),
                labelMedium: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 14,
                ),
                labelSmall: GoogleFonts.quicksand(
                  color: AppColors.black,
                  fontSize: 12,
                ),
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const RedirectionPage(),
              '/home': (context) => const HomePage(),
              '/events': (context) => const EventsPage(),
              '/all_events': (context) => const AllEventsOnProjectPage(),
              '/project': (context) => const ProjectPage(),
              '/my_contributions': (context) => const MyContributionsPage(),
              '/add_project': (context) => const AddProjectPage(),
              '/add_event': (context) => const AddEventPage(),
              '/profile': (context) => const ProfilePage(),
              '/profile_data': (context) => const ProfileData(),
              '/profile_data_edit': (context) => const EditProfileData(),
              '/admin': (context) => AdminPage(),
              '/admin_users': (context) => const AdminUsersPage(),
            },
            // home: const RedirectionPage(),
          );
        });
  }
}
