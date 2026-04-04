import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../resources/assets/colour_pallete.dart';
import '../resources/widgets/add_app_bar.dart';

class ProfileData extends StatefulWidget {
  const ProfileData({super.key});

  @override
  State<ProfileData> createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir conta'),
          content: const Text(
            'Essa ação não pode ser desfeita. A conta do usuário será excluída permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<UserController>().deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Widget displayInfo(String campo, String info, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 30,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20,
            vertical: MediaQuery.of(context).size.height / 200),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 12,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          border: Border.fromBorderSide(
              BorderSide(color: AppColors.primaryGreen, width: 2)),
          color: AppColors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${campo[0].toUpperCase()}${campo.substring(1)}:',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: MediaQuery.of(context).size.height / 50,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                info,
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: MediaQuery.of(context).size.height / 45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final user = userController.user;

    if (user == null) {
      return Scaffold(
        appBar: addAppBar(context, 'Perfil', isEdit: true, editFunction: () {
          Navigator.pushNamed(context, '/profile_data_edit');
        }),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: addAppBar(context, 'Perfil', isEdit: true, editFunction: () {
        Navigator.pushNamed(context, '/profile_data_edit');
      }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            displayInfo('Email', user.email ?? 'Não informado', context),
            displayInfo(
                'Profissão', user.occupation ?? 'Não informado', context),
            displayInfo(
                'Nascimento',
                user.bornAt != null
                    ? '${user.bornAt!.day}/'
                        ' ${user.bornAt!.month}/'
                        ' ${user.bornAt!.year}'
                    : 'Não informado',
                context),
            displayInfo('Estado', user.state ?? 'Não informado', context),
            displayInfo(
                'Cidade',
                user.countyName != null
                    ? user.countyName!
                    : user.county.toString(),
                context),
            displayInfo('Identidade étnico-racial',
                user.race ?? 'Não informado', context),
            displayInfo('Gênero', user.gender ?? 'Não informado', context),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 20,
                left: MediaQuery.of(context).size.width / 10,
                right: MediaQuery.of(context).size.width / 10,
                bottom: MediaQuery.of(context).size.height / 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 14,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () => _confirmDeleteAccount(context),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text(
                    'Excluir conta',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
