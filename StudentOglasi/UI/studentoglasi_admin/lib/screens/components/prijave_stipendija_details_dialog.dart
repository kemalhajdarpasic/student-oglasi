// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/utils/file_downloader.dart';
import 'package:studentoglasi_admin/utils/util.dart';

import '../../models/PrijaveStipendija/prijave_stipendija.dart';
import '../../providers/prijavestipendija_provider.dart';

class PrijavaStipendijaDetailsDialog extends StatefulWidget {
  String? title;
  PrijaveStipendija? prijaveStipendija;
  PrijavaStipendijaDetailsDialog({
    Key? key,
    this.title,
    this.prijaveStipendija,
  }) : super(key: key);

  @override
  State<PrijavaStipendijaDetailsDialog> createState() =>
      _PrijavaStipendijaDetailsDialogState();
}

class _PrijavaStipendijaDetailsDialogState
    extends State<PrijavaStipendijaDetailsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late PrijaveStipendijaProvider _PrijavaStipendijaProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _PrijavaStipendijaProvider = context.read<PrijaveStipendijaProvider>();

    _initialValue = {
      'prosjekOcjena':
          widget.prijaveStipendija?.student?.prosjecnaOcjena.toString(),
      'student.brojIndeksa': widget.prijaveStipendija?.student?.brojIndeksa,
      'student.fakultet': widget.prijaveStipendija?.student?.fakultet?.naziv,
      'student.ime': widget.prijaveStipendija?.student?.idNavigation?.ime,
      'student.prezime':
          widget.prijaveStipendija?.student?.idNavigation?.prezime,
      'student.email': widget.prijaveStipendija?.student?.idNavigation?.email,
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
            'Praksa: ${widget.prijaveStipendija?.stipendija?.idNavigation?.naslov}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Status prijave: ${widget.prijaveStipendija?.status?.naziv}',
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
                      child: FormBuilderTextField(
                        name: 'prosjekOcjena',
                        decoration: InputDecoration(
                          labelText: 'Prosjek Ocjena',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dokumenti:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  if (widget.prijaveStipendija?.dokumenti != null &&
                      widget.prijaveStipendija!.dokumenti!.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              widget.prijaveStipendija!.dokumenti!.map((dok) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: TextButton.icon(
                                icon: Icon(Icons.download, color: Colors.blue),
                                label: Text(
                                    dok.originalniNaziv ?? 'Nepoznato ime'),
                                onPressed: () {
                                  String fileUrl = FilePathManager.constructUrl(
                                      dok.naziv ?? '');
                                  String fileName =
                                      dok.originalniNaziv ?? 'dokument';
                                  downloadDocument(context, fileUrl, fileName);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Nema dostupnih dokumenata',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        if (widget.prijaveStipendija?.status?.naziv == "Na cekanju")
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _PrijavaStipendijaProvider.cancel(
                          widget.prijaveStipendija?.studentId,
                          entityId: widget.prijaveStipendija?.stipendijaId);

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
                      await _PrijavaStipendijaProvider.approve(
                          widget.prijaveStipendija?.studentId,
                          entityId: widget.prijaveStipendija?.stipendijaId);
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
