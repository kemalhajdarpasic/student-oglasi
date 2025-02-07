import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:studentoglasi_mobile/models/Rezervacije/rezervacije.dart';
import 'package:studentoglasi_mobile/providers/rezervacije_provider.dart';
import 'package:studentoglasi_mobile/providers/smjestaji_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodation_details_screen.dart';

class ReservationDetailsDialog extends StatefulWidget {
  final Rezervacije rezervacija;
  final Function()? onRezervacijaCancelled;
  final RezervacijeProvider rezervacijeProvider;
  final SmjestajiProvider smjestajiProvider;
  const ReservationDetailsDialog({
    super.key,
    required this.rezervacija,
    required this.rezervacijeProvider,
    required this.smjestajiProvider,
    this.onRezervacijaCancelled,
  });

  @override
  State<ReservationDetailsDialog> createState() =>
      _ReservationDetailsDialogDialogState();
}

class _ReservationDetailsDialogDialogState
    extends State<ReservationDetailsDialog> {
  @override
  Widget build(BuildContext context) {
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
                          onTap: () async {
                            if (widget.rezervacija.smjestaj?.id != null) {
                              var smjestaj = await widget.smjestajiProvider
                                  .getById(widget.rezervacija.smjestaj!.id!);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AccommodationDetailsScreen(
                                    smjestaj: smjestaj,
                                    averageRating: 0,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Smještaj nije pronađen.')),
                              );
                            }
                          },
                          child: Text(
                            widget.rezervacija.smjestaj?.naziv ?? 'No title',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          widget.rezervacija.smjestajnaJedinica?.naziv ??
                              "Nepoznata smjestajna jedinica",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.rezervacija.status?.naziv),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.rezervacija.status?.naziv ?? "Nepoznato",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (widget.rezervacija.datumPrijave != null &&
                  widget.rezervacija.datumOdjave != null)
                Text(
                  "${DateFormat('dd.MM.yyyy').format(widget.rezervacija.datumPrijave!)} - ${DateFormat('dd.MM.yyyy').format(widget.rezervacija.datumOdjave!)}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField("Ime i prezime",
                        "${widget.rezervacija.student?.idNavigation.ime ?? ''} ${widget.rezervacija.student?.idNavigation.prezime ?? ''}"),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoField(
                                "Broj indeksa",
                                widget.rezervacija.student?.brojIndeksa ??
                                    "Nije dostupno")),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildInfoField(
                                "Fakultet",
                                widget.rezervacija.student?.fakultet.naziv ??
                                    "Nije dostupno")),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoField(
                                "Datum prijave",
                                DateFormat('dd.MM.yyyy')
                                    .format(widget.rezervacija.datumPrijave!))),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildInfoField(
                                "Datum odjave",
                                DateFormat('dd.MM.yyyy')
                                    .format(widget.rezervacija.datumOdjave!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoField(
                            "Broj osoba",
                            widget.rezervacija.brojOsoba.toString(),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildInfoField(
                            "Cijena",
                            "${widget.rezervacija.cijena} KM",
                          ),
                        ),
                      ],
                    ),
                    _buildInfoField(
                      "Napomena/zahtjevi",
                      widget.rezervacija.napomena ?? "",
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Zatvori'),
                        ),
                        if (widget.rezervacija.status?.naziv?.toLowerCase() ==
                            'na cekanju')
                          ElevatedButton(
                            onPressed: () async {
                              bool? confirm =
                                  await _showConfirmationDialog(context);
                              if (confirm == true) {
                                try {
                                  bool isCancelled =
                                      await widget.rezervacijeProvider.cancel(
                                    widget.rezervacija.id
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isCancelled
                                          ? 'Rezervacija uspješno otkazana.'
                                          : 'Rezervacija nije otkazana.'),
                                    ),
                                  );
                                  if (isCancelled) {
                                    Navigator.pop(context);
                                    widget.onRezervacijaCancelled?.call();
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Greška: ${e.toString()}')),
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
        maxLines: label == "Napomena/zahtjevi" ? 3 : 1,
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

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Da li ste sigurni da želite otkazati rezervaciju?'),
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
