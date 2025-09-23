import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/views/home_page.dart';
import 'package:vidacoletiva/views/loading_page.dart';
import 'package:vidacoletiva/views/login_page.dart';
import 'package:vidacoletiva/views/consent_page.dart';
import 'package:vidacoletiva/views/edit_profile_data.dart';

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  bool declined = false;

  void _onAcceptConsent(UserController userController) async {
    await userController.acceptTermo();
    setState(() {
      declined = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EditProfileData()),
    );
  }

  void _onDeclineConsent() {
    setState(() {
      declined = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = Provider.of<UserController>(context);

    if (userController.isLoading) {
      return const LoadingPage();
    }
    if (userController.isLogged) {
      if (userController.user != null && userController.user!.termo == false) {
        if (declined) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Obrigado por acessar! Para usar o app, é necessário aceitar o termo de consentimento.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() => declined = false),
                    child: const Text('Ler e aceitar termo'),
                  ),
                ],
              ),
            ),
          );
        }
        return ConsentPage(
          onAccept: () => _onAcceptConsent(userController),
          onDecline: _onDeclineConsent,
        );
      }
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}