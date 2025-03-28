// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/PrijavePraksa/prijave_praksa.dart';
import 'package:studentoglasi_admin/providers/prijavepraksa_provider.dart';
import 'package:studentoglasi_admin/utils/file_downloader.dart';
import 'package:studentoglasi_admin/utils/util.dart';

class PrijavaPraksaDetailsDialog extends StatefulWidget {
  String? title;
  PrijavePraksa? prijavePraksa;
  PrijavaPraksaDetailsDialog({
    Key? key,
    this.title,
    this.prijavePraksa,
  }) : super(key: key);

  @override
  State<PrijavaPraksaDetailsDialog> createState() =>
      _PrijavaPraksaDetailsDialogState();
}

class _PrijavaPraksaDetailsDialogState
    extends State<PrijavaPraksaDetailsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late PrijavePraksaProvider _PrijavePraksaProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _PrijavePraksaProvider = context.read<PrijavePraksaProvider>();
/*  int? studentId;
  int? praksaId;
  String? propratnoPismo;
  String? cv;
  String? certifikati;
  int? statusId;
  Praksa? praksa;
  StatusPrijave? status;
  Student? student;*/
    _initialValue = {
      'propratnoPismo': widget.prijavePraksa?.propratnoPismo,
      'cv': widget.prijavePraksa?.cv,
      'certifikati': widget.prijavePraksa?.certifikati,
      'student.brojIndeksa': widget.prijavePraksa?.student?.brojIndeksa,
      'student.fakultet': widget.prijavePraksa?.student?.fakultet?.naziv,
      'student.ime': widget.prijavePraksa?.student?.idNavigation?.ime,
      'student.prezime': widget.prijavePraksa?.student?.idNavigation?.prezime,
      'student.email': widget.prijavePraksa?.student?.idNavigation?.email,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title ?? ''),
          SizedBox(height: 8.0),
          Text(
            'Praksa: ${widget.prijavePraksa?.praksa?.idNavigation?.naslov}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Status prijave: ${widget.prijavePraksa?.status?.naziv}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 400,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          FormBuilderTextField(
                            name: 'propratnoPismo',
                            decoration: InputDecoration(
                              labelText: 'Propratno pismo',
                              labelStyle: TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            enabled: false,
                            style: TextStyle(color: Colors.black),
                          ),
                          IconButton(
                            icon: Icon(Icons.download, color: Colors.blue),
                            onPressed: () {
                              String fileUrl = FilePathManager.constructUrl(
                                  widget.prijavePraksa?.propratnoPismo ?? '');
                              String fileName =
                                  widget.prijavePraksa?.propratnoPismo ?? '';

                              downloadDocument(context, fileUrl, fileName);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: 400,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          FormBuilderTextField(
                            name: 'cv',
                            decoration: InputDecoration(
                              labelText: 'CV',
                              labelStyle: TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            enabled: false,
                            style: TextStyle(color: Colors.black),
                          ),
                          IconButton(
                            icon: Icon(Icons.download, color: Colors.blue),
                            onPressed: () {
                              String fileUrl = FilePathManager.constructUrl(
                                  widget.prijavePraksa?.cv ?? '');
                              String fileName = widget.prijavePraksa?.cv ?? '';

                              downloadDocument(context, fileUrl, fileName);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 400,
                      child: FormBuilderTextField(
                        name: 'student.brojIndeksa',
                        decoration: InputDecoration(
                          labelText: 'Broj indeksa',
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: 400,
                      child: FormBuilderTextField(
                        name: 'student.fakultet',
                        decoration: InputDecoration(
                          labelText: 'Fakultet',
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 400,
                      child: FormBuilderTextField(
                        name: 'student.ime',
                        decoration: InputDecoration(
                          labelText: 'Ime',
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: 400,
                      child: FormBuilderTextField(
                        name: 'student.prezime',
                        decoration: InputDecoration(
                          labelText: 'Prezime',
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 400,
                      child: FormBuilderTextField(
                        name: 'student.email',
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: 400,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          FormBuilderTextField(
                            name: 'certifikati',
                            decoration: InputDecoration(
                              labelText: 'Certifikati',
                              labelStyle: TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            enabled: false,
                            style: TextStyle(color: Colors.black),
                          ),
                          IconButton(
                            icon: Icon(Icons.download, color: Colors.blue),
                            onPressed: () {
                              String fileUrl = FilePathManager.constructUrl(
                                  widget.prijavePraksa?.certifikati ?? '');
                              String fileName =
                                  widget.prijavePraksa?.certifikati ?? '';

                              downloadDocument(context, fileUrl, fileName);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        if (widget.prijavePraksa?.statusId == 2 ||
            widget.prijavePraksa?.status?.naziv == "Na cekanju")
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _PrijavePraksaProvider.cancel(
                          widget.prijavePraksa?.studentId,
                          entityId: widget.prijavePraksa?.praksaId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Prijava je uspješno otkazana!'),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                  'Došlo je do greške prilikom otkazivanja prijave.'),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Otkaži'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _PrijavePraksaProvider.approve(
                          widget.prijavePraksa?.studentId,
                          entityId: widget.prijavePraksa?.praksaId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Prijava je uspješno odobrena!'),
                            ],
                          ),
                          backgroundColor: Colors.lightGreen,
                        ),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Došlo je do greške. Molimo pokušajte opet!'),
                          ],
                        ),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                  child: Text('Odobri'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.lightGreen),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
      ],
    );
  }
}
