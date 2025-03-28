import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/Fakultet/fakultet.dart';
import 'package:studentoglasi_admin/models/NacinStudiranja/nacin_studiranja.dart';
import 'package:studentoglasi_admin/models/Smjer/smjer.dart';
import 'package:studentoglasi_admin/models/Student/student.dart';
import 'package:studentoglasi_admin/models/Univerzitet/univerzitet.dart';
import 'package:studentoglasi_admin/models/search_result.dart';
import 'package:studentoglasi_admin/providers/studenti_provider.dart';
import 'package:studentoglasi_admin/utils/util.dart';

class StudentUpdateDialog extends StatefulWidget {
  Student? student;
  SearchResult<Univerzitet>? univerzitetiResult;
  SearchResult<NacinStudiranja>? naciniStudiranjaResult;
  StudentUpdateDialog(
      {super.key,
      this.student,
      this.univerzitetiResult,
      this.naciniStudiranjaResult});

  @override
  State<StudentUpdateDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<StudentUpdateDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late StudentiProvider _studentProvider;
  String? _filePath;
  String? _imageUrl;
  Univerzitet? selectedUniverzitet;
  Fakultet? selectedFakultet;
  Smjer? selectedSmjer;
  final List<int> godine = [1, 2, 3, 4];
  int? selectedGodina;
  final List<Map<String, dynamic>> statusStudenta = [
    {'value': true, 'label': 'Aktivan'},
    {'value': false, 'label': 'Neaktivan'},
  ];
  bool? selectedStatus;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _studentProvider = context.read<StudentiProvider>();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.univerzitetiResult != null && widget.student != null) {
      selectedUniverzitet = widget.univerzitetiResult!.result.firstWhere(
        (univerzitet) =>
            univerzitet.id == widget.student!.fakultet?.univerzitetId,
      );
      selectedFakultet = selectedUniverzitet!.fakultetis?.firstWhere(
        (fakultet) => fakultet.id == widget.student?.fakultet?.id,
      );
      selectedSmjer = selectedFakultet?.smjerovi!
          .firstWhere((s) => s.id == widget.student?.smjer?.id);
      if (widget.student!.idNavigation?.slika != null) {
        _imageUrl =
            FilePathManager.constructUrl(widget.student!.idNavigation!.slika!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detalji studenta'),
      content: SingleChildScrollView(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue.shade800,
                onTap: (index) {
                  if (index == 1) {
                    if (!_formKey.currentState!.validate()) {
                      _tabController.animateTo(0);
                      return;
                    }
                  }

                  if (index == 0) {
                    if (!_formKey.currentState!.validate()) {
                      _tabController.animateTo(1);
                      return;
                    }
                  }
                },
                tabs: [
                  Tab(text: 'Osnovni podaci'),
                  Tab(text: 'Podaci o studiju'),
                ],
              ),
              SizedBox(
                height: 410,
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'idNavigation.ime': widget.student?.idNavigation?.ime,
                    'idNavigation.prezime':
                        widget.student?.idNavigation?.prezime,
                    'idNavigation.email': widget.student?.idNavigation?.email,
                    'brojIndeksa': widget.student?.brojIndeksa,
                    'univerzitetId': selectedUniverzitet?.id.toString(),
                    'smjerId': selectedSmjer?.id.toString(),
                    'nacinStudiranjaId':
                        widget.student?.nacinStudiranja?.id.toString(),
                    'fakultetId': selectedFakultet?.id.toString(),
                    'godinaStudija': widget.student?.godinaStudija,
                    'status': widget.student?.status,
                    'prosjecnaOcjena':
                        widget.student?.prosjecnaOcjena.toString()
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          FormBuilderField(
                                            name: 'filePath',
                                            builder: (FormFieldState<dynamic>
                                                field) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 200,
                                                    height: 200,
                                                    child: ClipOval(
                                                      child: _filePath != null
                                                          ? Image.file(
                                                              File(_filePath!),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : _imageUrl != null
                                                              ? Image.network(
                                                                  _imageUrl!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/user-icon.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.image,
                                                      );

                                                      if (result != null) {
                                                        setState(() {
                                                          _filePath = result
                                                              .files
                                                              .single
                                                              .path;
                                                        });
                                                        field.didChange(
                                                            _filePath);
                                                      }
                                                    },
                                                    child:
                                                        Text('Odaberite sliku'),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 0.5,
                                  height: 350,
                                  color: Colors.grey,
                                  margin: EdgeInsets.only(
                                      top: 50, left: 20, right: 40),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FormBuilderTextField(
                                        name: 'idNavigation.ime',
                                        decoration: InputDecoration(
                                          labelText: 'Ime',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              errorText: 'Ime je obavezno'),
                                          FormBuilderValidators.minLength(2,
                                              errorText:
                                                  'Ime mora imati najmanje 2 znaka'),
                                          FormBuilderValidators.maxLength(50,
                                              errorText:
                                                  'Ime može imati najviše 50 znakova'),
                                        ]),
                                      ),
                                      SizedBox(height: 20),
                                      FormBuilderTextField(
                                        name: 'idNavigation.prezime',
                                        decoration: InputDecoration(
                                          labelText: 'Prezime',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              errorText: 'Prezime je obavezno'),
                                          FormBuilderValidators.minLength(2,
                                              errorText:
                                                  'Prezime mora imati najmanje 2 znaka'),
                                          FormBuilderValidators.maxLength(50,
                                              errorText:
                                                  'Prezime može imati najviše 50 znakova'),
                                        ]),
                                      ),
                                      SizedBox(height: 20),
                                      FormBuilderTextField(
                                        name: 'idNavigation.email',
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              errorText: 'Email je obavezan'),
                                          FormBuilderValidators.email(
                                              errorText:
                                                  'Neispravan format email adrese'),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FormBuilderTextField(
                                        name: 'brojIndeksa',
                                        decoration: InputDecoration(
                                          labelText: 'Broj indeksa',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              errorText:
                                                  'Broj indeksa je obavezan'),
                                          FormBuilderValidators.maxLength(20,
                                              errorText:
                                                  'Broj indeksa može imati najviše 20 znakova'),
                                        ]),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: FormBuilderTextField(
                                        name: 'prosjecnaOcjena',
                                        decoration: InputDecoration(
                                          labelText: 'Prosječna ocjena',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              errorText:
                                                  'Prosječna ocjena je obavezna'),
                                          FormBuilderValidators.numeric(
                                              errorText:
                                                  'Prosječna ocjena mora biti numerička vrijednost'),
                                          FormBuilderValidators.min(6.0,
                                              errorText:
                                                  'Ocjena mora biti najmanje 6.0'),
                                          FormBuilderValidators.max(10.0,
                                              errorText:
                                                  'Ocjena može biti najviše 10.0'),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              FormBuilderDropdown<String>(
                                name: 'univerzitetId',
                                decoration: InputDecoration(
                                  labelText: 'Univerzitet',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: 'Univerzitet je obavezan'),
                                items: widget.univerzitetiResult?.result
                                        .map((Univerzitet univerzitet) =>
                                            DropdownMenuItem(
                                              value: univerzitet.id.toString(),
                                              child:
                                                  Text(univerzitet.naziv ?? ''),
                                            ))
                                        .toList() ??
                                    [],
                                onChanged: (selectedUniverzitetId) {
                                  setState(() {
                                    selectedUniverzitet = widget
                                        .univerzitetiResult?.result
                                        .firstWhere((univerzitet) =>
                                            univerzitet.id.toString() ==
                                            selectedUniverzitetId);
                                    selectedFakultet = null;
                                    selectedSmjer = null;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              FormBuilderDropdown<String>(
                                name: 'fakultetId',
                                decoration: InputDecoration(
                                  labelText: 'Fakultet',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: 'Fakultet je obavezan'),
                                enabled: selectedUniverzitet != null,
                                items: (selectedUniverzitet?.fakultetis ?? [])
                                        .map((Fakultet fakultet) =>
                                            DropdownMenuItem(
                                              value: fakultet.id.toString(),
                                              child: Text(fakultet.naziv ?? ''),
                                            ))
                                        .toList() ??
                                    [],
                                onChanged: (selectedFakultetId) {
                                  setState(() {
                                    selectedFakultet = selectedUniverzitet
                                        ?.fakultetis
                                        ?.firstWhere(
                                      (fakultet) =>
                                          fakultet.id.toString() ==
                                          selectedFakultetId,
                                    );
                                    selectedSmjer = null;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              FormBuilderDropdown<String>(
                                name: 'smjerId',
                                decoration: InputDecoration(
                                  labelText: 'Smjer',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: 'Smjer je obavezan'),
                                enabled: selectedFakultet != null,
                                items: (selectedFakultet?.smjerovi ?? [])
                                        .map((Smjer smjer) => DropdownMenuItem(
                                              value: smjer.id.toString(),
                                              child: Text(smjer.naziv ?? ''),
                                            ))
                                        .toList() ??
                                    [],
                                onChanged: (selectedSmjerId) {
                                  setState(() {
                                    selectedSmjer =
                                        selectedFakultet?.smjerovi?.firstWhere(
                                      (smjer) =>
                                          smjer.id.toString() ==
                                          selectedSmjerId,
                                    );
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: FormBuilderDropdown<int>(
                                      name: 'godinaStudija',
                                      decoration: InputDecoration(
                                        labelText: 'Godina studija',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: FormBuilderValidators.required(
                                          errorText:
                                              'Godina studija je obavezna'),
                                      items: godine
                                          .map((godina) =>
                                              DropdownMenuItem<int>(
                                                value: godina,
                                                child: Text('$godina. godina'),
                                              ))
                                          .toList(),
                                      onChanged: (selectedValue) {
                                        setState(() {
                                          selectedGodina = selectedValue;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: FormBuilderDropdown<String>(
                                      name: 'nacinStudiranjaId',
                                      decoration: InputDecoration(
                                        labelText: 'Način studiranja',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: FormBuilderValidators.required(
                                          errorText:
                                              'Način studiranja je obavezan'),
                                      items: widget
                                              .naciniStudiranjaResult?.result
                                              .map((NacinStudiranja
                                                      nacinStudiranja) =>
                                                  DropdownMenuItem(
                                                    value: nacinStudiranja.id
                                                        .toString(),
                                                    child: Text(
                                                        nacinStudiranja.naziv ??
                                                            ''),
                                                  ))
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Otkaži'),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.saveAndValidate()) {
              var request =
                  Map<String, dynamic>.from(_formKey.currentState!.value);
              request['idNavigation.korisnickoIme'] =
                  widget.student?.idNavigation?.korisnickoIme;

              request['brojIndeksa'] ??= widget.student?.brojIndeksa;
              request['godinaStudija'] ??= widget.student?.godinaStudija;
              request['prosjecnaOcjena'] ??=
                  widget.student?.prosjecnaOcjena.toString();
              request['univerzitetId'] ??= selectedUniverzitet?.id.toString();
              request['fakultetId'] ??= selectedFakultet?.id.toString();
              request['smjerId'] ??= selectedSmjer?.id.toString();
              request['nacinStudiranjaId'] ??=
                  widget.student?.nacinStudiranja?.id.toString();

              try {
                await _studentProvider.updateWithImage(
                    widget.student!.id!, request);
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Podaci su uspješno sačuvani!'),
                    ],
                  ),
                  backgroundColor: Colors.lightGreen,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Došlo je do greške. Molimo pokušajte ponovo!'),
                    ],
                  ),
                  backgroundColor: Colors.redAccent,
                ));
              }
            }
          },
          child: Text('Sačuvaj'),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blue.shade800),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
