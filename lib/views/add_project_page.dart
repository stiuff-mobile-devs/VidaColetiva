import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/project_controller.dart';
import 'package:vidacoletiva/resources/widgets/add_app_bar.dart';

import '../resources/assets/colour_pallete.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  @override
  Widget build(BuildContext context) {
    final ProjectController projectController =
        Provider.of<ProjectController>(context);

    return Scaffold(
      appBar: addAppBar(context, 'Criar um projeto',
          onPressed: () => projectController.createProject(context),
          isCheck: true,
          isLoading: projectController.isLoading),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: projectController.createProjectFormKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: formImage(),
                ),
                customFormField(
                  controller: projectController.institutionController,
                  info: 'a',
                  label: 'Instituição',
                  minLines: 1,
                  maxLines: 1,
                  tipo: TextInputType.text,
                ),
                customFormField(
                  controller: projectController.targetController,
                  info: 'o',
                  label: 'Publico alvo',
                  minLines: 1,
                  maxLines: 1,
                  tipo: TextInputType.text,
                ),
                customFormField(
                  controller: projectController.descriptionController,
                  info: 'a',
                  label: 'Descrição',
                  minLines: 5,
                  maxLines: 10,
                  tipo: TextInputType.multiline,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Projeto aberto ao público?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Switch(
                      value: projectController.isOpen,
                      onChanged: projectController.setIsOpen,
                      activeColor: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formImage() {
    final ProjectController projectController =
        Provider.of<ProjectController>(context);
    return Stack(
      children: [
        projectController.selectedImage == null
            ? Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[AppColors.grey, AppColors.primaryOrange]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(5, 5), // changes position of shadow
                    ),
                  ],
                ),
              )
            : Container(
                height: MediaQuery.of(context).size.height / 3.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                    image: FileImage(projectController.selectedImage!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(5, 5), // changes position of shadow
                    ),
                  ],
                ),
              ),
        Positioned(
          right: 0,
          child: IconButton(
              icon: const Icon(Icons.image_outlined),
              color: AppColors.white,
              onPressed: projectController.pickImageFromGallery),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.height / 50,
            ),
            child: TextFormField(
              controller: projectController.nameController,
              selectionControls: MaterialTextSelectionControls(),
              cursorColor: AppColors.white,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Informe o título do projeto...';
                }
                return null;
              },
              style: TextStyle(
                color: AppColors.white,
                fontSize: MediaQuery.of(context).size.height / 30,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Título do projeto',
                labelStyle: TextStyle(
                  color: AppColors.white,
                  fontSize: MediaQuery.of(context).size.height / 30,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .white, // Cor da barra inferior quando o campo está focado
                    width: 2.0,
                  ),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors
                        .white, // Cor da barra inferior quando o campo não está focado
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget customFormField({
    required TextEditingController controller,
    required String info,
    required String label,
    int? minLines,
    int? maxLines,
    TextInputType? tipo,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        keyboardType: tipo,
        controller: controller,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 40,
            color: AppColors.darkGreen),
        decoration: InputDecoration(
          hintText: 'Informe $info ${label.toLowerCase()}...',
          border: const OutlineInputBorder(),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.darkGreen),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors
                  .primaryOrange, // Cor da barra inferior quando o campo está focado
              width: 2.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors
                  .darkGreen, // Cor da barra inferior quando o campo não está focado
              width: 1,
            ),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Informe $info $label...';
          }
          return null;
        },
        cursorColor: AppColors.darkGreen,
        minLines: minLines,
        maxLines: maxLines,
      ),
    );
  }
}
