import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/PrijavaStipendija/prijave_stipendija.dart';
import 'package:studentoglasi_mobile/models/PrijavePraksa/prijave_praksa.dart';
import 'package:studentoglasi_mobile/models/Student/student.dart';
import 'package:studentoglasi_mobile/providers/prijavepraksa_provider.dart';
import 'package:studentoglasi_mobile/providers/prijavestipendija_provider.dart';
import 'package:studentoglasi_mobile/screens/scholarship_details_screen.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/internship_details_screen.dart';
import 'package:studentoglasi_mobile/widgets/applications/internship_application_details_dialog.dart';
import 'package:studentoglasi_mobile/widgets/applications/scholarship_application_details_dialog.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import '../widgets/menu.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late PrijavePraksaProvider _prijavePrakseProvider;
  late PrijaveStipendijaProvider _prijaveStipendijaProvider;
  late StudentiProvider _studentProvider;
  Student? _currentStudent;
  bool _isLoading = true;
  bool _hasError = false;
  List<PrijavePraksa>? prijavePrakseResult;
  List<PrijaveStipendija>? prijaveStipendijaResult;

  @override
  void initState() {
    super.initState();
    _prijavePrakseProvider = context.read<PrijavePraksaProvider>();
    _prijaveStipendijaProvider = context.read<PrijaveStipendijaProvider>();
    _studentProvider = context.read<StudentiProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _currentStudent = await _studentProvider.getCurrentStudent();
    try {
      var prakseData = await _prijavePrakseProvider
          .getPrijavePraksaByStudentId(_currentStudent!.id!);
      var stipendijeData = await _prijaveStipendijaProvider
          .getPrijaveStipendijaByStudentId(_currentStudent!.id!);
      setState(() {
        prijavePrakseResult = prakseData;
        prijaveStipendijaResult = stipendijeData;
        _isLoading = false;
      });
      print("Internship data fetched");
    } catch (e) {
      print("Failed to load internship data: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;
        final bool isLoggedIn = _studentProvider.isLoggedIn;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: isDesktop ? NavbarDesktop() : Text('Moje prijave'),
              bottom: TabBar(
                tabs: [
                  Tab(text: "Prakse"),
                  Tab(text: "Stipendije"),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ),
            drawer: isDesktop ? null : DrawerMenu(isLoggedIn: isLoggedIn,),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? const Center(
                            child: Text(
                                'Neuspješno učitavanje podataka. Molimo pokušajte opet.'))
                        : TabBarView(
                            children: [
                              _buildPrakseTab(),
                              _buildStipendijeTab(),
                            ],
                          ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrakseTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Sve"),
              Tab(text: "Odobrene"),
              Tab(text: "Na čekanju"),
              Tab(text: "Otkazane"),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPrakseList(null),
                _buildPrakseList("odobrena"),
                _buildPrakseList("na cekanju"),
                _buildPrakseList("otkazana"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStipendijeTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Sve"),
              Tab(text: "Odobrene"),
              Tab(text: "Na čekanju"),
              Tab(text: "Otkazane"),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStipendijeList(null),
                _buildStipendijeList("odobrena"),
                _buildStipendijeList("na cekanju"),
                _buildStipendijeList("otkazana"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrakseList(String? status) {
    List<PrijavePraksa> filteredList = prijavePrakseResult ?? [];

    if (status != null) {
      filteredList = filteredList
          .where((prijava) => prijava.status?.naziv?.toLowerCase() == status)
          .toList();
    }

    if (filteredList.isEmpty) {
      return const Center(child: Text('Nema prijava.'));
    }

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildPraksaCard(filteredList[index]);
      },
    );
  }

  Widget _buildStipendijeList(String? status) {
    List<PrijaveStipendija> filteredList = prijaveStipendijaResult ?? [];

    if (status != null) {
      filteredList = filteredList
          .where((prijava) => prijava.status?.naziv?.toLowerCase() == status)
          .toList();
    }

    if (filteredList.isEmpty) {
      return const Center(child: Text('Nema prijava.'));
    }

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildStipendijaCard(filteredList[index]);
      },
    );
  }

  Widget _buildPraksaCard(PrijavePraksa prijava) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (prijava.praksa != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipDetailsScreen(
                            internship: prijava.praksa!,
                            averageRating: 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    prijava.praksa?.idNavigation?.naslov ?? 'No title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                if (prijava.praksa?.organizacija?.naziv != null)
                  Text(
                    prijava.praksa!.organizacija!.naziv!,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                SizedBox(height: 4.0),
                if (prijava.praksa?.pocetakPrakse != null &&
                    prijava.praksa?.krajPrakse != null)
                  Text(
                    "Trajanje: ${DateFormat('dd.MM.yyyy').format(prijava.praksa!.pocetakPrakse!)} - ${DateFormat('dd.MM.yyyy').format(prijava.praksa!.krajPrakse)}",
                    style: TextStyle(fontSize: 14),
                  ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prijava.vrijemePrijave != null
                          ? "Datum prijave: ${DateFormat('dd.MM.yyyy').format(prijava.vrijemePrijave!)}"
                          : "Datum nepoznat",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 800 && prijava.status?.naziv?.toLowerCase() ==
                            'na cekanju')
                          ElevatedButton(
                            onPressed: () async {
                              bool? confirm =
                                  await _showConfirmationDialog(context);
                              if (confirm == true) {
                                try {
                                  bool isCancelled =
                                      await _prijavePrakseProvider.cancel(
                                    prijava.studentId,
                                    entityId: prijava.praksaId,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isCancelled
                                          ? 'Prijava uspješno otkazana.'
                                          : 'Prijava nije otkazana.'),
                                    ),
                                  );
                                  if (isCancelled) {
                                    await _fetchData();
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                            child: Text('Otkaži prijavu'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.red[300] ?? Colors.red),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            if (prijava.praksa != null) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    InternshipApplicationDetailsDialog(
                                  prijava: prijava,
                                  prijavePrakseProvider: _prijavePrakseProvider,
                                  onPrijavaCancelled: () {
                                    print("onPrijavaCancelled pozvan");
                                    setState(() {
                                      _fetchData();
                                    });
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Detalji prakse nisu dostupni.'),
                                ),
                              );
                            }
                          },
                          child: Text('Detalji'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(prijava.status?.naziv),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prijava.status?.naziv ?? 'Nepoznato',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildStipendijaCard(PrijaveStipendija prijava) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (prijava.stipendija != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScholarshipDetailsScreen(
                            scholarship: prijava.stipendija!,
                            averageRating: 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    prijava.stipendija?.idNavigation?.naslov ?? 'No title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                if (prijava.stipendija?.stipenditor?.naziv != null)
                  Text(
                    prijava.stipendija!.stipenditor!.naziv!,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prijava.vrijemePrijave != null
                          ? "Datum prijave: ${DateFormat('dd.MM.yyyy').format(prijava.vrijemePrijave!)}"
                          : "Datum nepoznat",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                         if (MediaQuery.of(context).size.width > 800 && prijava.status?.naziv?.toLowerCase() ==
                            'na cekanju')
                          ElevatedButton(
                            onPressed: () async {
                              bool? confirm =
                                  await _showConfirmationDialog(context);
                              if (confirm == true) {
                                try {
                                  bool isCancelled =
                                      await _prijaveStipendijaProvider.cancel(
                                          prijava.studentId,
                                          entityId: prijava.stipendijaId);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isCancelled
                                          ? 'Prijava uspješno otkazana.'
                                          : 'Prijava nije otkazana.'),
                                    ),
                                  );
                                  if (isCancelled) {
                                    await _fetchData();
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                            child: Text('Otkaži prijavu'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.red[300] ?? Colors.red),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            if (prijava.stipendija != null) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ScholarshipApplicationDetailsDialog(
                                  prijava: prijava,
                                  prijaveStipendijaProvider:
                                      _prijaveStipendijaProvider,
                                  onPrijavaCancelled: () {
                                    print("onPrijavaCancelled pozvan");
                                    setState(() {
                                      _fetchData();
                                    });
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Detalji prakse nisu dostupni.'),
                                ),
                              );
                            }
                          },
                          child: Text('Detalji'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(prijava.status?.naziv),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prijava.status?.naziv ?? 'Nepoznato',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
