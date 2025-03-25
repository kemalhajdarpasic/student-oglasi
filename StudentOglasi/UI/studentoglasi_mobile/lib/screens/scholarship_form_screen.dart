import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/screens/scholarships_screen.dart';
import '../providers/prijavestipendija_provider.dart';
import '../screens/main_screen.dart';

class PrijavaStipendijaFormScreen extends StatefulWidget {
  final Stipendije scholarship;

  const PrijavaStipendijaFormScreen({Key? key, required this.scholarship})
      : super(key: key);

  @override
  _PrijavaStipendijaFormScreenState createState() =>
      _PrijavaStipendijaFormScreenState();
}

class _PrijavaStipendijaFormScreenState
    extends State<PrijavaStipendijaFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late PrijaveStipendijaProvider _prijaveStipendijaProvider;
  Map<String, String?> _selectedFiles = {};
  Map<String, bool> _isHovered = {};

  Map<String, dynamic> _formData = {};

  List<PlatformFile> _selectedDokumentacija = [];

  @override
  void initState() {
    super.initState();
    _prijaveStipendijaProvider = context.read<PrijaveStipendijaProvider>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile(String fieldName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: fieldName == 'dokumentacija',
    );

    if (result != null) {
      setState(() {
        if (fieldName == 'cv') {
          var file = result.files.single;
          _selectedFiles[fieldName] = file.name;
          _formData['cv'] = kIsWeb ? file.bytes : file.path;
        } else if (fieldName == 'dokumentacija') {
          _selectedDokumentacija.addAll(result.files);

          _formData['dokumentacija'] =
              result.files.map((f) => kIsWeb ? f.bytes : f.path).toList();
          _formData['dokumentacija_imena'] =
              result.files.map((f) => f.name).toList();
        }
      });
    } else {
      print('No file selected');
    }
  }

  void _saveForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      _formData = {
        ..._formKey.currentState?.value ?? {},
        //'cv': _formData['cv'],
        'dokumentacija': _formData['dokumentacija'],
        'dokumentacija_imena': _formData['dokumentacija_imena'],
      };
    } else {
      print('Form validation failed');
    }
  }

  void _submitForm() async {
    _saveForm();

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final requestData = {
        'stipendijaId': widget.scholarship.id,
        'dokumentacija': _formData['dokumentacija'],
        'dokumentacija_imena': _formData['dokumentacija_imena'],
        //'cv': _formData['cv'] ?? ''
      };

      _sendDataToApi(requestData);
    } else {
      print('Form is not valid');
    }
  }

  void _sendDataToApi(Map<String, dynamic> formData) async {
    // print('Sending data to API: $formData');
    try {
      await _prijaveStipendijaProvider.insertFileMultipartData(formData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Prijava je uspešno poslana!'),
        backgroundColor: Colors.lightGreen,
      ));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScholarshipsScreen(),
        ),
      );
    } catch (e) {
      print('Error submitting application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Korisnik je već ste prijavljeni na ovu stipedniju.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Prijavi se na stipendiju'),
          centerTitle: true,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 600 : double.infinity;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormBuilder(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //_buildFilePickerField('CV', 'cv'),
                        FormBuilderField<List<PlatformFile>>(
                          name: 'dokumentacija',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Molimo Vas dodajte dokumentaciju.';
                            }
                            return null;
                          },
                          builder: (FormFieldState<List<PlatformFile>> field) {
                            bool isHovered =
                                _isHovered['dokumentacija'] ?? false;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: 'Dokumentacija',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Molimo Vas da dodate neophodnu dokumentaciju.',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                MouseRegion(
                                  onEnter: (_) => setState(
                                      () => _isHovered['dokumentacija'] = true),
                                  onExit: (_) => setState(() =>
                                      _isHovered['dokumentacija'] = false),
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _pickFile('dokumentacija');
                                      field.didChange(_selectedDokumentacija);
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        height: 300,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: field.hasError
                                                ? Colors.red
                                                : (isHovered
                                                    ? Colors.blue
                                                    : Colors.grey),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: _selectedDokumentacija.isEmpty
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.upload_file,
                                                      size: 30,
                                                      color: Colors.grey),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Kliknite da dodate dokumente (max 25MB)',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        _selectedDokumentacija
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        title: Text(
                                                          _selectedDokumentacija[
                                                                  index]
                                                              .name,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing: IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          onPressed: () {
                                                            _removeFile(index);
                                                            field.didChange(
                                                                _selectedDokumentacija);
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Divider(),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    '+ Kliknite kako biste dodali još dokumenata',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                  ),
                                ),
                                if (field.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      field.errorText ?? '',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text('Prijavi se'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }

  void _removeFile(int index) {
    setState(() {
      _selectedDokumentacija.removeAt(index);
      _formData['dokumentacija'] =
          _selectedDokumentacija.map((f) => kIsWeb ? f.bytes : f.path).toList();
    });
  }
}
