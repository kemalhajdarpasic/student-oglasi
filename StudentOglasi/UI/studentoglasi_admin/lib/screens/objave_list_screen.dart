// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/Kategorija/kategorija.dart';
import 'package:studentoglasi_admin/models/Objava/objava.dart';
import 'package:studentoglasi_admin/models/search_result.dart';
import 'package:studentoglasi_admin/providers/kategorije_provider.dart';
import 'package:studentoglasi_admin/providers/objave_provider.dart';
import 'package:studentoglasi_admin/widgets/master_screen.dart';
import 'package:intl/intl.dart';

class ObjaveListScreen extends StatefulWidget {
  const ObjaveListScreen({super.key});

  @override
  State<ObjaveListScreen> createState() => _ObjaveListScreenState();
}

class _ObjaveListScreenState extends State<ObjaveListScreen> {
  late ObjaveProvider _objaveProvider;
  late KategorijaProvider _kategorijeProvider;
  Kategorija? selectedKategorija;
  SearchResult<Objava>? result;
  SearchResult<Kategorija>? kategorijeResult;
  TextEditingController _naslovController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _objaveProvider = context.read<ObjaveProvider>();
    _kategorijeProvider = context.read<KategorijaProvider>();
    _fetchData();
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   _objaveProvider = context.read<ObjaveProvider>();
  // }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Novosti"),
      child: Container(
        child: Column(
          children: [_buildSearch(), _buildDataListView()],
        ),
      ),
    );
  }

  void _fetchData() async {
    var data =
        await _objaveProvider.get(filter: {'naslov': _naslovController.text});
    var kategorijeData = await _kategorijeProvider.get();
    setState(() {
      result = data;
      kategorijeResult = kategorijeData;
    });
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 10, 100, 0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Naslov",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                controller: _naslovController,
              ),
            ),
          ),
          SizedBox(width: 30.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: DropdownButton<Kategorija>(
                value: selectedKategorija,
                onChanged: (Kategorija? newValue) {
                  setState(() {
                    selectedKategorija = newValue;
                  });
                },
                items: kategorijeResult?.result.map((Kategorija kategorija) {
                      return DropdownMenuItem<Kategorija>(
                        value: kategorija,
                        child: Text(kategorija.naziv ?? ''),
                      );
                    }).toList() ??
                    [],
              ),
            ),
          ),
          SizedBox(width: 30),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: ElevatedButton(
                onPressed: () async {
                  // Navigator.of(context).pop();

                  var data = await _objaveProvider
                      .get(filter: {'naslov': _naslovController.text, 'kategorijaID':selectedKategorija?.id});
                  setState(() {
                    result = data;
                  });
                },
                child: Text("Filtriraj")),
          )
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(100, 30, 100, 0),
        child: IntrinsicWidth(
          stepWidth: double.infinity,
          child: DataTable(
              columns: [
                const DataColumn(
                  label: Expanded(
                    child: Text('Naslov',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center),
                  ),
                ),
                const DataColumn(
                  label: Expanded(
                    child: Text('Datum objave',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center),
                  ),
                ),
                const DataColumn(
                  label: Expanded(
                    child: Text('Kategorija',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center),
                  ),
                ),
                const DataColumn(
                  label: Expanded(
                    child: Text('Akcije',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center),
                  ),
                ),
              ],
              rows: result?.result
                      .map((Objava e) => DataRow(cells: [
                            DataCell(Center(
                                child: Text(
                              e.naslov ?? "",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))),
                            DataCell(Center(
                                child: Text(e.vrijemeObjave != null
                                    ? DateFormat('dd.MM.yyyy')
                                        .format(e.vrijemeObjave!)
                                    : ''))),
                            DataCell(
                                Center(child: Text(e.kategorija?.naziv ?? ""))),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // Handle edit action
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Handle delete action
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]))
                      .toList() ??
                  []),
        ),
      ),
    ));
  }
}