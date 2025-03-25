import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:studentoglasi_admin/models/PrijaveStipendija/prijave_stipendija.dart';
import 'package:studentoglasi_admin/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_admin/models/search_result.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/providers/prijavestipendija_provider.dart';

class PrijaveStipendijeReportDialog extends StatefulWidget {
  final List<Stipendije> stipendije;

  PrijaveStipendijeReportDialog({required this.stipendije});

  @override
  _PrijaveStipendijeReportDialogState createState() =>
      _PrijaveStipendijeReportDialogState();
}

class _PrijaveStipendijeReportDialogState
    extends State<PrijaveStipendijeReportDialog> {
  Stipendije? selectedStipendija;
  late PrijaveStipendijaProvider _PrijavaStipendijaProvider;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _PrijavaStipendijaProvider = context.read<PrijaveStipendijaProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Generiši izvještaj'),
      content: Container(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Naziv stipendije'),
                          SizedBox(height: 8),
                          DropdownButtonFormField<Stipendije>(
                            decoration: InputDecoration(
                              labelText: 'Stipendija',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedStipendija,
                            onChanged: (Stipendije? newValue) {
                              setState(() {
                                selectedStipendija = newValue;
                              });
                            },
                            items:
                                widget.stipendije.map((Stipendije stipendija) {
                              return DropdownMenuItem<Stipendije>(
                                value: stipendija,
                                child:
                                    Text(stipendija.idNavigation?.naslov ?? ''),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Molimo odaberite stipendiju.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await _PrijavaStipendijaProvider.printReport(
                  selectedStipendija!.id!, context);
            }
          },
          child: Icon(Icons.print),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final file = await _PrijavaStipendijaProvider.downloadReport(
                    selectedStipendija!.id!, context);

                if (file != null) {
                  OpenFile.open(file.path);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Preuzimanje izvještaja nije uspjelo.')));
              }
            }
          },
          child: Icon(Icons.download),
        ),
        ElevatedButton(
          child: Text('Generiši'),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blue.shade800),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(fontWeight: FontWeight.bold)),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              var reportData = await _fetchReportData(
                  context.read<PrijaveStipendijaProvider>());
              if (reportData != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Izvještaj',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      content: _buildReportDataTable(reportData),
                    );
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<SearchResult<PrijaveStipendija>?> _fetchReportData(
      PrijaveStipendijaProvider prijaveProvider) async {
    var reportData = await prijaveProvider.get(filter: {
      'stipendija': selectedStipendija!.id,
    });
    return reportData;
  }

  Widget _buildReportDataTable(SearchResult<PrijaveStipendija> reportData) {
    int countAccepted = 0;
    int countCnaceled = 0;
    if (reportData.result.map((e) => e.status?.naziv).contains("Odobrena")) {
      countAccepted++;
    } else if (reportData.result
        .map((e) => e.status?.naziv)
        .contains("Otkazana")) {
      countCnaceled++;
    }
    return Container(
      width: 794,
      height: 1123,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Naziv prakse: ${selectedStipendija?.idNavigation?.naslov ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Naziv stipenditora: ${selectedStipendija?.stipenditor?.naziv ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (reportData.count == 0)
            Expanded(
              child: Center(
                child: Text(
                  'Nema prijava za odabranu stipendiju.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 794,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        const DataColumn(
                          label: Expanded(
                            child: Text(
                              'Broj indeksa',
                              style: TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            child: Text(
                              'Ime i prezime',
                              style: TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            child: Text(
                              'Prosjek ocjena',
                              style: TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            child: Text(
                              'Status',
                              style: TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: reportData.result
                          .map((PrijaveStipendija e) => DataRow(cells: [
                                DataCell(Center(
                                    child: Text(e.student?.brojIndeksa ?? ""))),
                                DataCell(Center(
                                    child: Text(
                                        '${e.student?.idNavigation?.ime} ${e.student?.idNavigation?.prezime}'))),
                                DataCell(Center(
                                    child: Text(e.student!.prosjecnaOcjena.toString()))),
                                DataCell(Center(child: Text(e.status?.naziv ?? ""))),
                              ]))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ukupan broj prijava: ${reportData.count}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ukupan broj prihvaćenih prijava: ${countAccepted.toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ukupan broj odbijenih prijava: ${countCnaceled.toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Datum kreiranja izvještaja: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
