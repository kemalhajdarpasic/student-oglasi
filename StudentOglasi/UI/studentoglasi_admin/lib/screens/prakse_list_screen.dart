// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/models/Oglas/oglas.dart';
import 'package:studentoglasi_admin/models/Organizacije/organizacije.dart';
import 'package:studentoglasi_admin/models/Praksa/praksa.dart';
import 'package:studentoglasi_admin/models/StatusOglasi/statusoglasi.dart';
import 'package:studentoglasi_admin/models/search_result.dart';
import 'package:studentoglasi_admin/providers/oglasi_provider.dart';
import 'package:studentoglasi_admin/providers/organizacije_provider.dart';
import 'package:studentoglasi_admin/providers/prakse_provider.dart';
import 'package:studentoglasi_admin/providers/statusoglasi_provider.dart';
import 'package:studentoglasi_admin/screens/components/costum_paginator.dart';
import 'package:studentoglasi_admin/screens/components/praksa_details_dialog.dart';
import 'package:studentoglasi_admin/widgets/master_screen.dart';
import 'package:number_paginator/number_paginator.dart';

class PrakseListScreen extends StatefulWidget {
  const PrakseListScreen({super.key});

  @override
  State<PrakseListScreen> createState() => _PrakseListScreenState();
}

class _PrakseListScreenState extends State<PrakseListScreen> {
  late PraksaProvider _prakseProvider;
  late StatusOglasiProvider _statusProvider;
  late OrganizacijeProvider _organizacijeProvider;
  late OglasiProvider _oglasiProvider;
  Organizacije? selectedOrganizacije;
  StatusOglasi? selectedStatusOglasi;
  SearchResult<Organizacije>? organizacijeResult;
  SearchResult<StatusOglasi>? statusResult;
  SearchResult<Oglas>? oglasiResult;
  SearchResult<Praksa>? result;
  TextEditingController _naslovController = new TextEditingController();
  int _currentPage = 0;
  int _totalItems = 0;
  late NumberPaginatorController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prakseProvider = context.read<PraksaProvider>();
    _statusProvider = context.read<StatusOglasiProvider>();
    _organizacijeProvider = context.read<OrganizacijeProvider>();
    _oglasiProvider = context.read<OglasiProvider>();
    _pageController = NumberPaginatorController();
    _fetchData();
    _fetchOglasi();
    _fetchStatusOglasi();
    _fetchOrganizacije();
  }

  void _fetchStatusOglasi() async {
    var statusData = await _statusProvider.get();
    setState(() {
      statusResult = statusData;
    });
  }

  void _fetchOglasi() async {
    var oglasData = await _oglasiProvider.get();
    setState(() {
      oglasiResult = oglasData;
    });
  }

  void _fetchOrganizacije() async {
    var organizacijeData = await _organizacijeProvider.get();
    setState(() {
      organizacijeResult = organizacijeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    int numberPages = calculateNumberPages(_totalItems, 8);

    return MasterScreenWidget(
      title: "Prakse",
      addButtonLabel: "Dodaj praksu",
      onAddButtonPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => PraksaDetailsDialog(
                title: 'Dodaj praksu',
                praksa: null,
                statusResult: statusResult,
                organizacijeResult: organizacijeResult,
                oglasiResult: oglasiResult)).then((value) {
          if (value != null && value) {
            _fetchData();
          }
        });
      },
      child: Container(
        child: Column(
          children: [
            _buildSearch(),
            _buildDataListView(),
            if (_currentPage >= 0 && numberPages - 1 >= _currentPage)
              CustomPaginator(
                numberPages: numberPages,
                initialPage: _currentPage,
                onPageChange: (int index) {
                  setState(() {
                    _currentPage = index;
                    _fetchData();
                  });
                },
                pageController: _pageController,
                fetchData: _fetchData,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    print("login proceed");
    // Navigator.of(context).pop();

    var data = await _prakseProvider.get(filter: {
      'naslov': _naslovController.text,
      'organizacija': selectedOrganizacije?.id,
      'status': selectedStatusOglasi?.id,
      'page': _currentPage + 1,
      'pageSize': 8,
    });
    setState(() {
      result = data;
      _totalItems = data.count;
      int numberPages = calculateNumberPages(_totalItems, 8);
      if (_currentPage >= numberPages) {
        _currentPage = numberPages - 1;
      }
      if (_currentPage < 0) {
        _currentPage = 0;
      }
      print(
          "Total items: $_totalItems, Number of pages: $numberPages, Current page after fetch: $_currentPage");
    });

    print("data: ${data.result[0].idNavigation?.naslov}");
  }

  int calculateNumberPages(int totalItems, int pageSize) {
    return (totalItems / pageSize).ceil();
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 10, 100, 0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Naziv"),
                controller: _naslovController,
              ),
            ),
          ),
          SizedBox(width: 30.0),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: DropdownButton2<StatusOglasi>(
                isExpanded: true,
                hint: Text('Status oglasa'),
                value: selectedStatusOglasi,
                onChanged: (StatusOglasi? newValue) {
                  setState(() {
                    selectedStatusOglasi = newValue;
                  });
                },
                items: statusResult?.result.map((StatusOglasi status) {
                      return DropdownMenuItem<StatusOglasi>(
                        value: status,
                        child: Text(status.naziv ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14)),
                      );
                    }).toList() ??
                    [],
              ),
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0), // Align dropdown
              child: DropdownButton2<Organizacije>(
                isExpanded: true,
                hint: Text('Organizacija'),
                value: selectedOrganizacije,
                onChanged: (Organizacije? newValue) {
                  setState(() {
                    selectedOrganizacije = newValue;
                  });
                },
                items:
                    organizacijeResult?.result.map((Organizacije organizacija) {
                          return DropdownMenuItem<Organizacije>(
                            value: organizacija,
                            child: Text(organizacija.naziv ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14)),
                          );
                        }).toList() ??
                        [],
              ),
            ),
          ),
          SizedBox(width: 20.0),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _fetchData();
                  },
                  child: Text("Filtriraj"),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    _naslovController.clear();
                    setState(() {
                      selectedStatusOglasi = null;
                      selectedOrganizacije = null;
                    });
                    _fetchData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 240, 92, 92),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Očisti filtere"),
                ),
              ],
            ),
          ),
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
              columnSpacing: 15,
              columns: [
                DataColumn(
                  label: Container(
                    width: 150,
                    child: Text(
                      'Naslov',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      'Početak prakse',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      'Rok prijave',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      'Organizacija',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      'Status',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      'Akcije',
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              rows: result?.result
                      .map((Praksa e) => DataRow(
                            cells: [
                              DataCell(Container(
                                width: 250,
                                child: Text(
                                  e.idNavigation?.naslov ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                ),
                              )),
                              DataCell(Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: Text(e.pocetakPrakse != null
                                    ? DateFormat('dd.MM.yyyy')
                                        .format(e.pocetakPrakse!)
                                    : ''),
                              )),
                              DataCell(Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: Text(e.idNavigation?.rokPrijave != null
                                    ? DateFormat('dd.MM.yyyy')
                                        .format(e.idNavigation!.rokPrijave)
                                    : ''),
                              )),
                              DataCell(Container(
                                width: 150,
                                child: Text(
                                  e.organizacija?.naziv ?? "",
                                  overflow: TextOverflow.clip,
                                ),
                              )),
                              DataCell(Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text(e.status?.naziv ?? ""),
                              )),
                              DataCell(Container(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              PraksaDetailsDialog(
                                            title: 'Detalji prakse',
                                            praksa: e,
                                            statusResult: statusResult,
                                            organizacijeResult:
                                                organizacijeResult,
                                            oglasiResult: oglasiResult,
                                          ),
                                        ).then((value) {
                                          if (value != null && value) {
                                            _fetchData();
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Potvrda brisanja"),
                                                  IconButton(
                                                    icon: Icon(Icons.close),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              content: Text(
                                                  "Da li ste sigurni da želite izbrisati?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text("Ne"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: Text("Da"),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmDelete == true) {
                                          await _prakseProvider.delete(e.id);
                                          await _fetchData();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ))
                      .toList() ??
                  [],
            ),
          ),
        ),
      ),
    );
  }
}
