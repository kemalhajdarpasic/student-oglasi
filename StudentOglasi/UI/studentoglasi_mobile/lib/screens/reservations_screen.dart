import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Rezervacije/rezervacije.dart';
import 'package:studentoglasi_mobile/models/Student/student.dart';
import 'package:studentoglasi_mobile/providers/rezervacije_provider.dart';
import 'package:studentoglasi_mobile/providers/smjestaji_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodation_details_screen.dart';
import 'package:studentoglasi_mobile/widgets/menu.dart';
import 'package:studentoglasi_mobile/widgets/reservation_details_dialog.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late RezervacijeProvider _rezeracijeProvider;
  late StudentiProvider _studentProvider;
  late SmjestajiProvider _smjestajProvider;
  Student? _currentStudent;
  bool _isLoading = true;
  bool _hasError = false;
  List<Rezervacije>? rezeracijeResult;

  @override
  void initState() {
    super.initState();
    _rezeracijeProvider = context.read<RezervacijeProvider>();
    _studentProvider = context.read<StudentiProvider>();
    _smjestajProvider = context.read<SmjestajiProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _currentStudent = await _studentProvider.getCurrentStudent();
    try {
      var data = await _rezeracijeProvider
          .getRezervacijeByStudentId(_currentStudent!.id!);
      setState(() {
        rezeracijeResult = data;
        _isLoading = false;
      });
      print("Reservation data fetched");
    } catch (e) {
      print("Failed to load reservation data: $e");
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

        return Scaffold(
          appBar: AppBar(
            title: isDesktop ? NavbarDesktop() : Text('Moje rezervacije'),
          ),
          drawer: isDesktop ? null : DrawerMenu(),
          body: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? const Center(
                          child: Text(
                              'Neuspješno učitavanje podataka. Molimo pokušajte opet.'))
                      : _buildSmjestajTab(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmjestajTab() {
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
                _buildSmjestajList(null),
                _buildSmjestajList("odobrena"),
                _buildSmjestajList("na cekanju"),
                _buildSmjestajList("otkazana"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmjestajList(String? status) {
    List<Rezervacije> filteredList = rezeracijeResult ?? [];

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
        return _buildSmjestajCard(filteredList[index]);
      },
    );
  }

  Widget _buildSmjestajCard(Rezervacije rezervacija) {
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
                  onTap: () async {
                    if (rezervacija.smjestaj?.id != null) {
                      var smjestaj = await _smjestajProvider
                          .getById(rezervacija.smjestaj!.id!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccommodationDetailsScreen(
                            smjestaj: smjestaj,
                            averageRating: 0,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Smještaj nije pronađen.')),
                      );
                    }
                  },
                  child: Text(
                    rezervacija.smjestajnaJedinica?.naziv ?? 'No title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                if (rezervacija.smjestaj?.naziv != null)
                  Text(
                    rezervacija.smjestaj!.naziv!,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                SizedBox(height: 4.0),
                if (rezervacija.datumPrijave != null &&
                    rezervacija.datumOdjave != null)
                  Text(
                    "Rezervacija za dane: ${DateFormat('dd.MM.yyyy').format(rezervacija.datumPrijave!)} - ${DateFormat('dd.MM.yyyy').format(rezervacija.datumOdjave!)}",
                    style: TextStyle(fontSize: 14),
                  ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rezervacija.vrijemeKreiranja != null
                          ? "Kreirano: ${DateFormat('dd.MM.yyyy').format(rezervacija.vrijemeKreiranja!)}"
                          : "Datum nepoznat",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        if (rezervacija.status?.naziv?.toLowerCase() ==
                            'na cekanju')
                          ElevatedButton(
                            onPressed: () async {
                              bool? confirm =
                                  await _showConfirmationDialog(context);
                              if (confirm == true) {
                                try {
                                  bool isCancelled =
                                      await _rezeracijeProvider.cancel(
                                    rezervacija.id
                                  );

                                  if (isCancelled) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Rezervacija uspješno otkazana.')),
                                    );
                                    _fetchData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Rezervacija nije otkazana.')),
                                    );
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
                            child: Text('Otkaži rezervaciju'),
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
                          onPressed: () async {
                            try {
                              if (rezervacija.smjestaj?.id != null) {
                                 showDialog(
                                context: context,
                                builder: (context) =>
                                    ReservationDetailsDialog(
                                  rezervacija: rezervacija,
                                  rezervacijeProvider: _rezeracijeProvider,
                                  smjestajiProvider: _smjestajProvider,
                                  onRezervacijaCancelled: () {
                                    setState(() {
                                      _fetchData();
                                    });
                                  },
                                ),);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Smještaj nije pronađen.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Greška: ${e.toString()}')),
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
                color: _getStatusColor(rezervacija.status?.naziv),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rezervacija.status?.naziv ?? 'Nepoznato',
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
