import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/user_controller.dart';
import 'package:vidacoletiva/data/models/estado_model.dart';
import 'package:vidacoletiva/data/models/municipio_model.dart';
import 'package:vidacoletiva/data/models/user_model.dart';
import '../resources/assets/colour_pallete.dart';
import '../resources/widgets/add_app_bar.dart';

class EditProfileData extends StatefulWidget {
  const EditProfileData({super.key});

  @override
  State<EditProfileData> createState() => _EditProfileDataState();
}

class _EditProfileDataState extends State<EditProfileData> {
  String? selectedState;
  String? selectedCity;
  String? selectedEthnicity;
  String? selectedGender;
  String? selectedOccupation;
  String? selectedBirth;

  DateTime? birthDate;

  String? siglaEstado;
  int? idMunicipio;

  UserModel createdModel = UserModel.fromJson({});

  Estado? selectedEstado;
  Municipio? selectedMunicipio;

  late UserController userController;

  @override
  initState() {
    userController = Provider.of<UserController>(context, listen: false);
    UserModel u = userController.user!;
    selectedGender = u.gender;
    selectedState = u.state;
    selectedEthnicity = u.race;
    selectedOccupation = u.occupation;
    selectedState = u.state;
    siglaEstado = u.state;
    selectedCity = "${u.county}";
    idMunicipio = u.county;
    if (u.bornAt != null) {
      DateTime birthDate = u.bornAt!;
      selectedBirth =
          "${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}";
    }
    super.initState();
  }

  void pickDate() async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          birthDate = date;
          selectedBirth =
              "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
        });
      }
    });
  }

  Future<List<Estado>> getStates() async {
    List<String> tempStates = [];
    await http
        .get(Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/estados'))
        .then((response) {
      var json = jsonDecode(response.body);
      for (var state in json) {
        tempStates.add(state['nome']);
      }
    });
    return Estado.buscaTodosEstados();
  }

  save() async {
    Map<String, dynamic> data = {
      if (selectedState != null) 'state': selectedState,
      if (selectedOccupation != null) 'occupation': selectedOccupation,
      if (selectedEthnicity != null) 'race': selectedEthnicity,
      if (selectedGender != null) 'gender': selectedGender,
      if (selectedMunicipio != null) 'county': selectedMunicipio!.id,
      if (selectedMunicipio != null) 'county_name': selectedMunicipio!.nome,
      if (siglaEstado != null) 'state': siglaEstado,
      if (birthDate != null) 'born_at': birthDate,
    };
    if (data.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }
    await userController.save(data);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: addAppBar(context, 'Editar Perfil', onPressed: () {
        save();
      }, isCheck: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // textForm('Nome completo', 'Fulano da Silva Santos', context, (String value) {
            //   u.name = value;
            // }),
            textForm('Profissão', selectedOccupation ?? "", context,
                (String value) {
              selectedOccupation = value;
            }),
            birthDayWidget(),
            // textForm('Nascimento', selectedBirth ?? "", context,
            //     (String value) {
            //   // u.birth = value;
            // }),
            statesWidget(),
            dropdownMenu(
                'Identidade étnico-racial',
                ['Branco', 'Preto', 'Indígena', 'Pardo', 'Amarelo/ Asiático'],
                context,
                selectedEthnicity, (String? value) {
              setState(() {
                selectedEthnicity = value;
              });
            }),
            dropdownMenu(
                'Gênero',
                [
                  'Mulher cisgênero',
                  'Homem cisgênero',
                  'Outro',
                  'Prefiro não declarar'
                ],
                context,
                selectedGender, (String? value) {
              setState(() {
                selectedGender = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget birthDayWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 30,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: GestureDetector(
        onTap: () {
          pickDate();
        },
        child: Container(
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20,
            vertical: MediaQuery.of(context).size.height / 200,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
          child: Text(
            'Nascimento: ' + (selectedBirth ?? ""),
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontSize: MediaQuery.of(context).size.height / 50,
            ),
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: EdgeInsets.only(
    //     top: MediaQuery.of(context).size.height / 30,
    //     left: MediaQuery.of(context).size.width / 10,
    //     right: MediaQuery.of(context).size.width / 10,
    //   ),
    //   child: TextFormField(
    //     cursorColor: AppColors.primaryOrange,
    //     initialValue: initialValue,
    //     onChanged: onChanged,
    //     style: const TextStyle(
    //       color: AppColors.primaryOrange,
    //     ),
    //     decoration: InputDecoration(
    //       fillColor: AppColors.white,
    //       labelText: label,
    //       labelStyle: const TextStyle(
    //         color: AppColors.primaryGreen,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       focusedBorder: OutlineInputBorder(
    //         borderSide: const BorderSide(
    //           color: AppColors.primaryGreen,
    //           width: 3,
    //         ),
    //         borderRadius: BorderRadius.circular(100),
    //       ),
    //       enabledBorder: OutlineInputBorder(
    //         borderSide: const BorderSide(
    //           color: AppColors.primaryGreen,
    //           width: 2,
    //         ),
    //         borderRadius: BorderRadius.circular(100),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget dropdownMenu(String label, List<String> items, BuildContext context,
      String? state, Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 30,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.primaryGreen,
              ),
              elevation: 2,
            ),
            hint: Text(
              label,
              style: TextStyle(
                color: AppColors.primaryOrange,
              ),
            ),
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: state,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  textForm(String label, String initialValue, BuildContext context,
      Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 30,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: TextFormField(
        cursorColor: AppColors.primaryOrange,
        initialValue: initialValue,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.primaryOrange,
        ),
        decoration: InputDecoration(
          fillColor: AppColors.white,
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget statesWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 30,
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Estado>>(
              future: getStates(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                List<Estado> listaEstados = snapshot.data!;
                listaEstados.sort((a, b) {
                  return a.nome!.compareTo(b.nome!);
                });

                return Padding(
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: MediaQuery.of(context).size.height / 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.primaryGreen,
                          ),
                          elevation: 2,
                        ),
                        hint: const Text(
                          "Estado",
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        items: listaEstados
                            .map((item) => DropdownMenuItem<String>(
                                  value: item.sigla,
                                  child: Text(
                                    item.nome ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryOrange,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: siglaEstado,
                        onChanged: (v) {
                          setState(
                            () {
                              idMunicipio = null;
                              siglaEstado = v;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            siglaEstado != null
                ? Column(
                    children: [
                      const SizedBox(height: 25),
                      FutureBuilder<List<Municipio>>(
                        future:
                            Municipio.buscaMunicipiosPorEstado(siglaEstado!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const CircularProgressIndicator();
                          List<Municipio> listaEstados = snapshot.data!;
                          return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                labelText: "Municipio",
                                labelStyle: const TextStyle(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              hint: const Text("Municipio",
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                  )),
                              value: idMunicipio,
                              items: listaEstados
                                  .map((municipio) => DropdownMenuItem<int>(
                                        value: municipio.id,
                                        child: Text(
                                          municipio.nome!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryOrange,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            selectedMunicipio = municipio;
                                          });
                                        },
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(
                                  () {
                                    idMunicipio = v;
                                  },
                                );
                              });
                        },
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 0,
                  ),
          ]),
    );
  }
}
