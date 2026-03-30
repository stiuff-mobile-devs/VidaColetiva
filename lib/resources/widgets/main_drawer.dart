import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:vidacoletiva/utils/eula.dart';
import 'package:vidacoletiva/services/report_service.dart';

import '../assets/colour_pallete.dart';

Widget textButton(String text, BuildContext context, Function onPressed) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width / 20,
        vertical: MediaQuery.of(context).size.height / 60),
    child: TextButton(
      onPressed: () {
        onPressed();
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 60),
        backgroundColor: AppColors.primaryOrange,
      ),
      child: Text(text,
          style: TextStyle(
              color: AppColors.white,
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.bold)),
    ),
  );
}

Widget mainDrawer(BuildContext context) {
  UserController userController = Provider.of<UserController>(context);

  return Drawer(
    width: MediaQuery.of(context).size.width / 1.5,
    backgroundColor: AppColors.tertiaryOrange,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: AppColors.tertiaryOrange,
            border: Border(
              bottom: BorderSide(
                color: Colors.transparent,
              ),
            ),
          ),
          child: Center(
            child: Text('Olá! ${userController.getDisplayName().split(' ')[0]}',
                style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: MediaQuery.of(context).size.height / 30,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        textButton('Perfil', context, () {
          Navigator.pushNamed(context, '/profile');
        }),
        // textButton('Preferências', context, () {}),
        textButton('Meu Relatório', context, () {
          _generateUserMediaReport(context);
        }),
        textButton('Sobre o app', context, () {
          _showAboutApp(context);
        }),
        textButton('Termos legais', context, () {
          _showEula(context);
        }),
        // textButton('Avaliar app', context, () {}),
        if (userController.isSuperAdmin)
          textButton('Gerar relatório geral', context, () {
            _generateMediaReport(context);
          }),
        if (userController.isSuperAdmin)
          textButton('Administração', context, () {
            Navigator.pushNamed(context, '/admin');
          }),
        if (userController.isSuperAdmin)
          textButton('Gerenciar usuários', context, () {
            Navigator.pushNamed(context, '/admin_users');
          }),
        textButton('Sair', context, () {
          userController.logout();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }),
      ],
    ),
  );
}

Future<void> _showAboutApp(BuildContext context) async {
  final outerContext = context;
  String version = 'desconhecida';
  try {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
  } catch (_) {}

  final email = 'projetorelatoscotidianos.coc.esr@id.uff.br';
  final site = 'vidacoletiva.uff.br';
  final double titleFont = 22;
  final double bodyFont = 18;
  final double contactFont = 20;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Sobre o app',
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: titleFont,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O aplicativo é desenvolvido pelo laboratório no.ar da UFF, conta com a parceria da STI‑UFF e teve apoio financeiro da Faperj e da UFF',
            style: TextStyle(
              fontSize: bodyFont,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dúvidas ou sugestões:',
            style: TextStyle(
              fontSize: bodyFont,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: email));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(outerContext).showSnackBar(
                SnackBar(content: Text('Email copiado: $email')),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.email,
                    color: AppColors.primaryOrange, size: contactFont + 6),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      decoration: TextDecoration.underline,
                      fontSize: contactFont,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mais informações:',
            style: TextStyle(
              fontSize: bodyFont,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: site));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(outerContext).showSnackBar(
                SnackBar(content: Text('Link copiado: $site')),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.link,
                    color: AppColors.primaryOrange, size: contactFont + 4),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    site,
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      decoration: TextDecoration.underline,
                      fontSize: contactFont - 2,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Versão: $version',
            style: TextStyle(
              fontSize: bodyFont - 2,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> _showEula(BuildContext context) async {
  final double titleFont = 20;
  final double bodyFont = 16;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        'Termos e Consentimento',
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: titleFont,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Text(
              Eula.eulaText,
              style: TextStyle(
                fontSize: bodyFont,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fechar', style: TextStyle(fontSize: bodyFont - 1)),
        ),
      ],
    ),
  );
}

Future<void> _generateUserMediaReport(BuildContext context) async {
  final outerContext = context;

  // Mostrar diálogo de carregamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryOrange),
          const SizedBox(height: 16),
          Text(
            'Gerando seu relatório...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    ),
  );

  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final reportService = ReportService();
    final file = await reportService.generateUserMediaReport(userId);

    // Fechar diálogo de carregamento
    Navigator.of(outerContext).pop();

    // Mostrar diálogo de sucesso
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Sucesso!',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Seu relatório foi gerado com sucesso!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final reportService = ReportService();
                await reportService.shareReport(file);
              } catch (e) {
                ScaffoldMessenger.of(outerContext).showSnackBar(
                  SnackBar(content: Text('Erro ao compartilhar: $e')),
                );
              }
            },
            child: Text(
              'Compartilhar',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    // Fechar diálogo de carregamento
    Navigator.of(outerContext).pop();

    // Mostrar diálogo de erro
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Erro',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Erro ao gerar seu relatório: $e',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _generateMediaReport(BuildContext context) async {
  final outerContext = context;

  // Mostrar diálogo de carregamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryOrange),
          const SizedBox(height: 16),
          Text(
            'Gerando relatório...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    ),
  );

  try {
    final reportService = ReportService();
    final file = await reportService.generateMediaReport();

    // Fechar diálogo de carregamento
    Navigator.of(outerContext).pop();

    // Mostrar diálogo de sucesso
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Sucesso!',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Relatório gerado com sucesso!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final reportService = ReportService();
                await reportService.shareReport(file);
              } catch (e) {
                ScaffoldMessenger.of(outerContext).showSnackBar(
                  SnackBar(content: Text('Erro ao compartilhar: $e')),
                );
              }
            },
            child: Text(
              'Compartilhar',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    // Fechar diálogo de carregamento
    Navigator.of(outerContext).pop();

    // Mostrar diálogo de erro
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Erro',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Erro ao gerar relatório: $e',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
