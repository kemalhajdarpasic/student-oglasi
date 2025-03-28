// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/Kategorija/kategorija.dart';
import 'package:studentoglasi_admin/models/Objava/objava.dart';
import 'package:studentoglasi_admin/models/search_result.dart';
import 'package:studentoglasi_admin/providers/objave_provider.dart';
import 'package:studentoglasi_admin/utils/util.dart';

class ObjaveDetailsDialog extends StatefulWidget {
  String? title;
  Objava? objava;
  SearchResult<Kategorija>? kategorijeResult;
  ObjaveDetailsDialog(
      {super.key, this.title, this.objava, this.kategorijeResult});

  @override
  _ObjaveDetailsDialogState createState() => _ObjaveDetailsDialogState();
}

class _ObjaveDetailsDialogState extends State<ObjaveDetailsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ObjaveProvider _objaveProvider;
  String? _filePath;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _objaveProvider = context.read<ObjaveProvider>();
  
    if (widget.objava != null && widget.objava!.slika != null) {
      _imageUrl = FilePathManager.constructUrl(widget.objava!.slika!);
    }

    _initialValue = {
      'naslov': widget.objava?.naslov,
      'sadrzaj': widget.objava?.sadrzaj,
      'kategorijaId': widget.objava?.kategorijaId.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? ''),
      content: SingleChildScrollView(
        child:ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
          child: FormBuilder(
            key: _formKey,
            initialValue: _initialValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                FormBuilderField(
                  name: 'filePath',
                  builder: (FormFieldState<dynamic> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Slika',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorText: field.errorText,
                          ),
                          child: Center(
                            child: _filePath != null
                                ? Image.file(
                                    File(_filePath!),
                                    fit: BoxFit.cover,
                                    width: 800,
                                    height: 350,
                                  )
                                : _imageUrl != null
                                    ? Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        width: 800,
                                        height: 350,
                                      )
                                    : SizedBox(
                                        width: 800,
                                        height: 350,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              'Nema dostupne slike',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _filePath != null ? _filePath! : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image);
          
                                if (result != null) {
                                  setState(() {
                                    _filePath = result.files.single.path;
                                  });
                                  field.didChange(_filePath);
                                }
                              },
                              child: Text('Odaberite sliku'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 400,
                        child: FormBuilderTextField(
                          name: 'naslov',
                          decoration: InputDecoration(
                            labelText: 'Naslov',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'Naslov je obavezan'),
                            FormBuilderValidators.maxLength(100,
                                errorText:
                                    'Naslov može imati najviše 100 znakova'),
                          ]),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: FormBuilderDropdown<String>(
                        name: 'kategorijaId',
                        decoration: InputDecoration(
                          labelText: 'Kategorija',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: widget.kategorijeResult?.result
                                .map((Kategorija kategorija) => DropdownMenuItem(
                                      value: kategorija.id.toString(),
                                      child: Text(kategorija.naziv ?? ''),
                                    ))
                                .toList() ??
                            [],
                        validator: FormBuilderValidators.required(
                            errorText: 'Kategorija je obavezna'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'sadrzaj',
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Sadržaj',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'Sadržaj je obavezan'),
                    FormBuilderValidators.minLength(10,
                        errorText: 'Sadržaj mora imati najmanje 10 znakova'),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Otkaži'),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.saveAndValidate()) {
              var request =
                  Map<String, dynamic>.from(_formKey.currentState!.value);

              try {
                if (widget.objava == null) {
                  await _objaveProvider.insertWithImage(request);
                } else {
                  await _objaveProvider.updateWithImage(
                      widget.objava!.id!, request);
                }

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
              } on Exception catch (e) {
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
