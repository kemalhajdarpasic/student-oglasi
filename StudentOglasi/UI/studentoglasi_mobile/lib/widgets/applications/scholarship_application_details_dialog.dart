import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studentoglasi_mobile/models/PrijavaStipendija/prijave_stipendija.dart';
import 'package:studentoglasi_mobile/providers/prijavestipendija_provider.dart';
import 'package:studentoglasi_mobile/screens/scholarship_details_screen.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

class ScholarshipApplicationDetailsDialog extends StatefulWidget {
  final PrijaveStipendija prijava;
  final Function()? onPrijavaCancelled;
  final PrijaveStipendijaProvider prijaveStipendijaProvider;
  const ScholarshipApplicationDetailsDialog({
    super.key,
    required this.prijava,
    required this.prijaveStipendijaProvider,
    this.onPrijavaCancelled,
  });

  @override
  State<ScholarshipApplicationDetailsDialog> createState() =>
      _ScholarshipApplicationDetailsDialogState();
}

class _ScholarshipApplicationDetailsDialogState
    extends State<ScholarshipApplicationDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final prijava = widget.prijava;
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            if (prijava.stipendija != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ScholarshipDetailsScreen(
                                    scholarship: prijava.stipendija!,
                                    averageRating: 0,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            prijava.stipendija?.idNavigation?.naslov ??
                                "Nije dostupno",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Text(
                          prijava.stipendija?.stipenditor?.naziv ??
                              "Nepoznat stipenditor",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(prijava.status?.naziv),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prijava.status?.naziv ?? "Nepoznato",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField("Ime i prezime",
                        "${prijava.student?.idNavigation.ime ?? ''} ${prijava.student?.idNavigation.prezime ?? ''}"),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoField(
                                "Broj indeksa",
                                prijava.student?.brojIndeksa ??
                                    "Nije dostupno")),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildInfoField(
                                "Fakultet",
                                prijava.student?.fakultet.naziv ??
                                    "Nije dostupno")),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoField(
                                "Email",
                                prijava.student?.idNavigation.email ??
                                    "Nije dostupno")),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildInfoField(
                                "Prosjek ocjena",
                                prijava.student?.prosjecnaOcjena?.toString() ??
                                    "Nije dostupno")),
                      ],
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text("Dokumenti:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildDownloadButton(
                            "Propratna dokumentacija", prijava.dokumentacija),
                        _buildDownloadButton("CV", prijava.cv),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Zatvori'),
                            ),
                            if (prijava.status?.naziv?.toLowerCase() ==
                                'na cekanju')
                              ElevatedButton(
                                onPressed: () async {
                                  bool? confirm =
                                      await _showConfirmationDialog(context);
                                  if (confirm == true) {
                                    try {
                                      bool isCancelled = await widget
                                          .prijaveStipendijaProvider
                                          .cancel(prijava.studentId,
                                              entityId: prijava.stipendijaId);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(isCancelled
                                              ? 'Prijava uspješno otkazana.'
                                              : 'Prijava nije otkazana.'),
                                        ),
                                      );
                                      if (isCancelled) {
                                        Navigator.pop(context);
                                        widget.onPrijavaCancelled?.call();
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  }
                                },
                                child: Text('Otkaži prijavu'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red[300] ?? Colors.red),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  textStyle: MaterialStateProperty.all<
                                          TextStyle>(
                                      TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'odobrena':
        return Colors.green.shade400.withOpacity(0.8);
      case 'na cekanju':
        return Colors.orange.shade400.withOpacity(0.8);
      case 'otkazana':
        return Colors.red.shade400.withOpacity(0.8);
      default:
        return Colors.blue.shade200.withOpacity(0.8);
    }
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: FormBuilderTextField(
        name: label,
        initialValue: value,
        enabled: false,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(String label, String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return Text('$label: Nije dostupno');
    }

    String fileUrl = FilePathManager.constructUrl(fileName);

    return TextButton.icon(
      onPressed: () async {
        if (await canLaunchUrl(Uri.parse(fileUrl))) {
          await launchUrl(Uri.parse(fileUrl),
              mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Neuspješno otvaranje URL-a: $fileUrl');
        }
      },
      icon: Icon(Icons.download),
      label: Text(label),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Da li ste sigurni da želite otkazati prijavu?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Ne'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Da'),
            ),
          ],
        );
      },
    );
  }
}
