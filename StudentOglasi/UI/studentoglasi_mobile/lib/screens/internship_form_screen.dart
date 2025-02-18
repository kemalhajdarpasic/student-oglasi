import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import '../providers/prijavepraksa_provider.dart';
import '../screens/main_screen.dart';
import 'package:flutter/foundation.dart';

class PrijavaPraksaFormScreen extends StatefulWidget {
  final Praksa internship;

  const PrijavaPraksaFormScreen({Key? key, required this.internship})
      : super(key: key);

  @override
  _PrijavaPraksaFormScreenState createState() =>
      _PrijavaPraksaFormScreenState();
}

class _PrijavaPraksaFormScreenState extends State<PrijavaPraksaFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late PrijavePraksaProvider _prijavaPraksaProvider;
  Map<String, String?> _selectedFiles = {};
  Map<String, bool> _isHovered = {};

  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _prijavaPraksaProvider = context.read<PrijavePraksaProvider>();
  }

  Future<void> _pickFile(String fieldName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      var file = result.files.single;
      setState(() {
        _selectedFiles[fieldName] = file.name;
        _formData[fieldName] = kIsWeb ? file.bytes : file.path;
        print('Odabran fajl za $fieldName: ${_formData[fieldName]}');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected.')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      _formData = {
        ..._formKey.currentState?.value ?? {},
        'praksaId': widget.internship.id,
        'propratnoPismo': _formData['propratnoPismo'],
        'certifikati': _formData['certifikati'],
        'cv': _formData['cv'] ?? '',
      };

      try {
        await _prijavaPraksaProvider.insertFileMultipartData(_formData);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ObjavaListScreen(),
        ));
      } catch (e) {
        print('Error submitting application: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Molimo popunite sva obavezna polja.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Prijavi se na praksu'),
          centerTitle: true,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 600 : double.infinity;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilePickerField('Certifikati', 'certifikati'),
                        SizedBox(height: 10),
                        Divider(thickness: 1, color: Colors.grey[200]),
                        SizedBox(height: 10),
                        _buildFilePickerField('CV', 'cv'),
                        SizedBox(height: 10),
                        Divider(thickness: 1, color: Colors.grey[200]),
                        SizedBox(height: 10),
                        _buildFilePickerField(
                            'Propratno pismo', 'propratnoPismo'),
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

  Widget _buildFilePickerField(String label, String fieldName) {
    return FormBuilderField(
      name: fieldName,
      validator: (value) {
        if (fieldName == 'cv' &&
            (_selectedFiles[fieldName] == null ||
                _selectedFiles[fieldName]!.isEmpty)) {
          return 'CV je obavezan.';
        }
        return null;
      },
      builder: (FormFieldState<dynamic> field) {
        bool isFileSelected = _selectedFiles[fieldName] != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                children: [
                  if (fieldName == 'cv')
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text(
              fieldName == 'cv'
                  ? 'Odaberite svoj CV dokument.'
                  : fieldName == 'certifikati'
                      ? 'Dodajte certifikate ako ih imate.'
                      : 'Dodajte propratno pismo.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 5),
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered[fieldName] = true),
              onExit: (_) => setState(() => _isHovered[fieldName] = false),
              child: GestureDetector(
                onTap: () => _pickFile(fieldName),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError
                          ? Colors.red
                          : (_isHovered[fieldName] == true
                              ? Colors.blue
                              : Colors.grey),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isFileSelected
                      ? SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedFiles[fieldName]!,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _pickFile(fieldName),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                    ),
                                    child: Text(
                                      'Promijeni fajl',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () => _removeFile(fieldName),
                                    icon: Icon(Icons.delete,
                                        color: Colors.blue, size: 28),
                                    tooltip: 'Izbriši fajl',
                                  ),
                                ],
                              )
                            ],
                          ),
                      )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file,
                                size: 30, color: Colors.grey),
                            SizedBox(height: 5),
                            Text('Dodajte dokument (max 25MB)',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  void _removeFile(String fieldName) {
    setState(() {
      _selectedFiles.remove(fieldName);
    });
  }
}
