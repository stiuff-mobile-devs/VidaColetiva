import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/resources/widgets/add_app_bar.dart';

import '../resources/assets/colour_pallete.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isValidHttpUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      appBar: addAppBar(context, 'Perfil', onPressed: () {
        Navigator.pop(context);
      }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 30),
                child: Text(
                  _firebaseAuth.currentUser!.displayName ?? "-",
                  style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 30),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipOval(
                child: _isValidHttpUrl(userController.photoUrl)
                    ? Image.network(
                        userController.photoUrl!.trim(),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                            child: const Icon(Icons.person, size: 72),
                          );
                        },
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        child: const Icon(Icons.person, size: 72),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                  vertical: MediaQuery.of(context).size.height / 25),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile_data');
                },
                style: TextButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width / 1.5,
                      MediaQuery.of(context).size.height / 15),
                  backgroundColor: AppColors.primaryOrange,
                ),
                child: Text('Meus dados',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: MediaQuery.of(context).size.height / 40,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
