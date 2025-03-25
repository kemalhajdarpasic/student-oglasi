// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/Rezervacije/rezervacije.dart';
import 'package:studentoglasi_admin/providers/rezervacije_provider.dart';

class RezervacijeDetailsDialog extends StatefulWidget {
  String? title;
  Rezervacije? rezervacija;
  RezervacijeDetailsDialog({
    Key? key,
    this.title,
    this.rezervacija,
  }) : super(key: key);

  @override
  State<RezervacijeDetailsDialog> createState() =>
      _RezervacijeDetailsDialogState();
}

class _RezervacijeDetailsDialogState extends State<RezervacijeDetailsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late RezervacijeProvider _RezervacijeProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _RezervacijeProvider = context.read<RezervacijeProvider>();
    /*  int? studentId;
  int? smjestajnaJedinicaId;
  DateTime? datumPrijave;
  DateTime? datumOdjave;
  int? brojOsoba;
  String? napomena;
  int? statusId;
  SmjestajnaJedinica? smjestajnaJedinica;
  SmjestajBasic? smjestaj;
  StatusPrijave? status;
  Student? student;*/
    _initialValue = {
      'datumPrijave': widget.rezervacija?.datumPrijave != null
          ? DateFormat('dd.MM.yyyy').format(widget.rezervacija!.datumPrijave!)
          : '',
      'datumOdjave': widget.rezervacija?.datumOdjave != null
          ? DateFormat('dd.MM.yyyy').format(widget.rezervacija!.datumOdjave!)
          : '',
      'brojOsoba': widget.rezervacija?.brojOsoba.toString(),
      'napomena': widget.rezervacija?.napomena,
      'cijena': widget.rezervacija?.cijena.toString(),
      'student.brojIndeksa': widget.rezervacija?.student?.brojIndeksa,
      'student.fakultet': widget.rezervacija?.student?.fakultet?.naziv,
      'student.imePrezime':
          '${widget.rezervacija?.student?.idNavigation?.ime} ${widget.rezervacija?.student?.idNavigation?.prezime}',
      'student.email': widget.rezervacija?.student?.idNavigation?.email,
    };
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
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
            'Naziv smještaja: ${widget.rezervacija?.smjestaj?.naziv}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Smještajna jedinica: ${widget.rezervacija?.smjestajnaJedinica?.naziv}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Status prijave: ${widget.rezervacija?.status?.naziv}',
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
                        name: 'student.imePrezime',
                        decoration: InputDecoration(
                          labelText: 'Ime i prezime',
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
                        name: 'datumPrijave',
                        decoration: InputDecoration(
                          labelText: 'Datum prijave',
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
                        name: 'datumOdjave',
                        decoration: InputDecoration(
                          labelText: 'Datum odjave',
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
                        name: 'brojOsoba',
                        decoration: InputDecoration(
                          labelText: 'Broj osoba',
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
                        name: 'cijena',
                        decoration: InputDecoration(
                            labelText: 'Cijena',
                            labelStyle: TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            suffixText: 'KM'),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'napomena',
                decoration: InputDecoration(
                  labelText: 'Napomena/zahtjevi',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                enabled: false,
                style: TextStyle(color: Colors.black),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.rezervacija?.statusId == 2 ||
            widget.rezervacija?.status?.naziv == "Na cekanju")
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _RezervacijeProvider.cancel(widget.rezervacija?.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Rezervacija je uspješno otkazana!'),
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
                      await _RezervacijeProvider.approve(
                          widget.rezervacija?.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Rezervacija je uspješno odobrena!'),
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
