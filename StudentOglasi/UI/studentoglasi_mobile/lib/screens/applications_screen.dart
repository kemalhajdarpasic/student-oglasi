import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Organizacije/organizacije.dart';
import 'package:studentoglasi_mobile/models/PrijavaStipendija/prijave_stipendija.dart';
import 'package:studentoglasi_mobile/models/PrijavePraksa/prijave_praksa.dart';
import 'package:studentoglasi_mobile/models/Rezervacije/rezervacije.dart';
import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/models/StatusOglas/statusoglasi.dart';
import 'package:studentoglasi_mobile/models/StatusPrijave/statusprijave.dart';
import 'package:studentoglasi_mobile/models/Student/student.dart';
import 'package:studentoglasi_mobile/providers/prijavepraksa_provider.dart';
import 'package:studentoglasi_mobile/providers/prijavestipendija_provider.dart';
import 'package:studentoglasi_mobile/providers/rezervacije_provider.dart';
import 'package:studentoglasi_mobile/providers/smjestaji_provider.dart';
import 'package:studentoglasi_mobile/screens/scholarship_details_screen.dart';
import 'package:studentoglasi_mobile/providers/statusprijave_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/internship_details_screen.dart';
import 'package:studentoglasi_mobile/screens/accommodation_details_screen.dart';
import '../models/search_result.dart';
import '../widgets/menu.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late PrijavePraksaProvider _prijavePrakseProvider;
  late PrijaveStipendijaProvider _prijaveStipendijaProvider;
  late RezervacijeProvider _rezeracijeProvider;
  late StudentiProvider _studentProvider;
  late SmjestajiProvider _smjestajProvider;
  Student? _currentStudent;
  bool _isLoading = true;
  bool _hasError = false;
  List<PrijavePraksa>? prijavePrakseResult;
  List<PrijaveStipendija>? prijaveStipendijaResult;
  List<Rezervacije>? rezeracijeResult;

  @override
  void initState() {
    super.initState();
    _prijavePrakseProvider = context.read<PrijavePraksaProvider>();
    _prijaveStipendijaProvider = context.read<PrijaveStipendijaProvider>();
    _studentProvider = context.read<StudentiProvider>();
    _rezeracijeProvider = context.read<RezervacijeProvider>();
    _smjestajProvider = context.read<SmjestajiProvider>();
    _fetchData();
    _fetchScholarshipData();
    _fetchReservationsData();
  }

  Future<void> _fetchData() async {
    _currentStudent = await _studentProvider.getCurrentStudent();
    try {
      var data = await _prijavePrakseProvider
          .getPrijavePraksaByStudentId(_currentStudent!.id!);
      setState(() {
        prijavePrakseResult = data
            .where((prijava) => prijava.status?.naziv != 'Otkazana')
            .toList();
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

  Future<void> _fetchScholarshipData() async {
    _currentStudent = await _studentProvider.getCurrentStudent();
    try {
      var data = await _prijaveStipendijaProvider
          .getPrijaveStipendijaByStudentId(_currentStudent!.id!);
      setState(() {
        prijaveStipendijaResult = data
            .where((prijava) => prijava.status?.naziv != 'Otkazana')
            .toList();
        _isLoading = false;
      });
      print("Scholarship data fetched");
    } catch (e) {
      print("Failed to load scholarship data: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchReservationsData() async {
    _currentStudent = await _studentProvider.getCurrentStudent();
    try {
      var data = await _rezeracijeProvider
          .getRezervacijeByStudentId(_currentStudent!.id!);
      setState(() {
        rezeracijeResult = data
            .where((rezervacija) => rezervacija.status?.naziv != 'Otkazana')
            .toList();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Moje prijave'),
      ),
      drawer: DrawerMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text(
                      'Neuspješno učitavanje podataka. Molimo pokušajte opet.'))
              : prijavePrakseResult == null &&
                      prijaveStipendijaResult == null &&
                      rezeracijeResult == null
                  ? const Center(child: Text('Trenutno nema prijava.'))
                  : ListView.builder(
                      itemCount: (prijavePrakseResult?.length ?? 0) +
                          (prijaveStipendijaResult?.length ?? 0) +
                          (rezeracijeResult?.length ?? 0),
                      itemBuilder: (context, index) {
                        if (index < (prijavePrakseResult?.length ?? 0)) {
                          // Internship applications
                          final prijava = prijavePrakseResult![index];
                          return _buildPraksaCard(prijava);
                        } else if (index <
                            (prijavePrakseResult?.length ?? 0) +
                                (prijaveStipendijaResult?.length ?? 0)) {
                          // Scholarship applications
                          final scholarshipIndex =
                              index - (prijavePrakseResult?.length ?? 0);
                          final prijava =
                              prijaveStipendijaResult![scholarshipIndex];
                          return _buildScholarshipCard(prijava);
                        } else {
                          // Reservations
                          final reservationIndex = index -
                              (prijavePrakseResult?.length ?? 0) -
                              (prijaveStipendijaResult?.length ?? 0);
                          final rezervacija =
                              rezeracijeResult![reservationIndex];
                          return _buildReservationCard(rezervacija);
                        }
                      },
                    ),
    );
  }

  Widget _buildPraksaCard(PrijavePraksa prijava) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naziv oglasa za praksu: \n${prijava.praksa?.idNavigation?.naslov ?? 'No title'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      try {
                        bool isCancelled = await _prijavePrakseProvider.cancel(
                          prijava.studentId,
                          entityId: prijava.praksaId,
                        );

                        if (isCancelled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Prijava uspješno otkazana.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Prijava nije otkazana.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text('Otkaži'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Detalji stipendije nisu dostupni.')),
                      );
                    }
                  },
                  child: Text('Pogledaj oglas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarshipCard(PrijaveStipendija prijava) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naziv oglasa za stipendiju: \n${prijava.stipendija?.idNavigation?.naslov ?? 'No title'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      try {
                        bool isCancelled = await _prijaveStipendijaProvider
                            .cancel(prijava.studentId,
                                entityId: prijava.stipendijaId);

                        if (isCancelled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Prijava uspješno otkazana.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Prijava nije otkazana.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text('Otkaži'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Detalji stipendije nisu dostupni.')),
                      );
                    }
                  },
                  child: Text('Pogledaj oglas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(Rezervacije rezervacija) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naziv oglasa za smještaj: \n${rezervacija.smjestaj?.naziv ?? 'No title'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      try {
                        bool isCancelled = await _rezeracijeProvider.cancel(
                          rezervacija.studentId,
                          entityId: rezervacija.smjestaj?.id,
                        );

                        if (isCancelled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Rezervacija uspješno otkazana.')),
                          );
                          _fetchData();
                          _fetchReservationsData();
                          _fetchScholarshipData();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Rezervacija nije otkazana.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text('Otkaži'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (rezervacija.smjestaj?.id != null) {
                        var smjestaj = await _smjestajProvider
                            .getById(rezervacija.smjestaj!.id!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccommodationDetailsScreen(
                              smjestaj: smjestaj,
                              averageRating:
                                  0,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Smještaj nije pronađen.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Greška: ${e.toString()}')),
                      );
                    }
                  },
                  child: Text('Pogledaj oglas'),
                ),
              ],
            ),
          ],
        ),
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
