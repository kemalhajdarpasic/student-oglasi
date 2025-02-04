import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/SmjestajnaJedinica/smjestajna_jedinica.dart';
import 'package:studentoglasi_mobile/models/ZauzetiTermini/zauzeti_termini.dart';
import 'package:studentoglasi_mobile/providers/payment_provider.dart';
import 'package:studentoglasi_mobile/providers/rezervacije_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'payment/payment_handler_mobile.dart'
    if (dart.library.js) 'payment/payment_handler_web.dart';

class ReservationScreen extends StatefulWidget {
  final SmjestajnaJedinica jedinica;

  const ReservationScreen({Key? key, required this.jedinica}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  int _numberOfGuests = 1;
  double _totalPrice = 0.0;
  TextEditingController _notesController = TextEditingController();
  PaymentProvider? paymentProvider;
  List<ZauzetiTermini> zauzetiTermini = [];

  String? _paymentIntentSecret;

  @override
  void initState() {
    super.initState();
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    final reservationProvider =
        Provider.of<RezervacijeProvider>(context, listen: false);

    final zauzetiTerminiResult =
        await reservationProvider.getZauzetiTermini(widget.jedinica.id!);

    setState(() {
      zauzetiTermini = zauzetiTerminiResult;
    });
  }

  void _onDaySelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (start != null) {
      setState(() {
        _rangeStart = start;
        _rangeEnd = null;
        _focusedDay = focusedDay;
      });
    }

    if (start != null && end != null) {
      bool isOverlapping = zauzetiTermini.any((termin) {
        if (termin.datumPrijave == null || termin.datumOdjave == null)
          return false;
        return start.isBefore(termin.datumOdjave!.add(Duration(days: 1))) &&
            end.isAfter(termin.datumPrijave!);
      });
      if (isOverlapping) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Odabrani period sadrži zauzete termine.')),
        );
        return;
      }

      setState(() {
        _rangeEnd = end;
        _calculateTotalPrice();
      });
    }
  }

  void _calculateTotalPrice() {
    if (_rangeStart != null && _rangeEnd != null) {
      int numberOfDays = _rangeEnd!.difference(_rangeStart!).inDays;
      _totalPrice = numberOfDays * (widget.jedinica.cijena ?? 0);
    }
  }

  void _handlePayment() async {
    if (_totalPrice > 0 && paymentProvider != null) {
      await PaymentHandler.handlePayment(
        context,
        _totalPrice,
        paymentProvider!,
        _confirmReservation,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cijena mora biti veća od 0 za uplatu.')),
      );
    }
  }

  void _confirmReservation() async {
    if (_rangeStart != null && _rangeEnd != null && _numberOfGuests > 0) {
      var studentiProvider =
          Provider.of<StudentiProvider>(context, listen: false);
      var studentId = studentiProvider.currentStudent?.id;

      if (studentId == null) {
        var student = await studentiProvider.getCurrentStudent();
        studentId = student.id;
      }

      // final rezervacija = RezervacijeInsert(
      //   studentId,
      //   widget.jedinica.id,
      //   _startDate,
      //   _endDate,
      //   _numberOfGuests,
      //   _notesController.text,
      //   _totalPrice,
      // );

      Map<String, dynamic> rezervacija = {
        "studentId": studentId,
        "smjestajnaJedinicaId": widget.jedinica.id,
        "datumPrijave": _rangeStart!.toIso8601String(),
        "datumOdjave": _rangeEnd!.toIso8601String(),
        "brojOsoba": _numberOfGuests,
        "napomena":
            _notesController.text.isNotEmpty ? _notesController.text : null,
        "cijena": _totalPrice
      };

      try {
        var rezervacijeProvider =
            Provider.of<RezervacijeProvider>(context, listen: false);
        await rezervacijeProvider.insertJsonData(rezervacija);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rezervacija je uspješno potvrđena!')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Došlo je do greške prilikom rezervacije')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Molimo unesite sve podatke za rezervaciju.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rezervišite smještaj'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Expanded(
                            //   flex: 2,
                            //   child: _buildInfoSection(),
                            // ),

                            Expanded(
                              flex: 3,
                              child: _buildCalendarSection(),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 26.0),
                                child: _buildFormSection(isDesktop),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildPaymentButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  SizedBox(height: 16),
                  _buildCalendarSection(),
                  SizedBox(height: 16),
                  _buildFormSection(isDesktop),
                  SizedBox(height: 16),
                  _buildPaymentButton(),
                ],
              ),
            );
          }
        },
      ),
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(
      //           '${widget.jedinica.naziv}',
      //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //           textAlign: TextAlign.center,
      //         ),
      //         SizedBox(height: 16),
      //         Text(
      //           'Odaberite period rezervacije', // Dodani naslov iznad kalendara
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 8),
      //         Container(
      //           decoration: BoxDecoration(
      //             color: const Color.fromARGB(255, 238, 247, 254),
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           padding: EdgeInsets.all(8),
      //           child: Column(
      //             children: [
      //               TableCalendar(
      //                 focusedDay: _focusedDay,
      //                 firstDay: DateTime.now(),
      //                 lastDay: DateTime(2100),
      //                 rangeSelectionMode: RangeSelectionMode.toggledOn,
      //                 selectedDayPredicate: (day) =>
      //                     isSameDay(_rangeStart, day) ||
      //                     isSameDay(_rangeEnd, day),
      //                 rangeStartDay: _rangeStart,
      //                 rangeEndDay: _rangeEnd,
      //                 onRangeSelected: (start, end, focusedDay) {
      //                   _onDaySelected(start, end, focusedDay);
      //                 },
      //                 calendarStyle: CalendarStyle(
      //                   selectedDecoration: BoxDecoration(
      //                     color: Colors.blue,
      //                     shape: BoxShape.circle,
      //                   ),
      //                   rangeStartDecoration: BoxDecoration(
      //                     color: Colors.green,
      //                     shape: BoxShape.circle,
      //                   ),
      //                   rangeEndDecoration: BoxDecoration(
      //                     color: Colors.red,
      //                     shape: BoxShape.circle,
      //                   ),
      //                 ),
      //                 calendarBuilders: CalendarBuilders(
      //                   defaultBuilder: (context, day, focusedDay) {
      //                     bool isBooked = zauzetiTermini.any((termin) {
      //                       if (termin.datumPrijave == null ||
      //                           termin.datumOdjave == null) return false;
      //                       return termin.datumPrijave != null &&
      //                           termin.datumOdjave != null &&
      //                           (day.difference(termin.datumPrijave!).inDays ==
      //                                   0 ||
      //                               day
      //                                       .difference(termin.datumOdjave!)
      //                                       .inDays ==
      //                                   0 ||
      //                               (day.isAfter(termin.datumPrijave!) &&
      //                                   day.isBefore(termin.datumOdjave!)));
      //                     });
      //                     return Container(
      //                       margin: EdgeInsets.all(4),
      //                       decoration: BoxDecoration(
      //                         color: isBooked ? Colors.red : Colors.transparent,
      //                         shape: BoxShape.circle,
      //                       ),
      //                       child: Center(
      //                         child: Text(
      //                           '${day.day}',
      //                           style: TextStyle(
      //                             color: isBooked ? Colors.white : Colors.black,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                 ),
      //               ),
      //               SizedBox(height: 10),
      //               Padding(
      //                 padding: const EdgeInsets.only(left: 5.0),
      //                 child: Row(
      //                   children: [
      //                     Container(
      //                       width: 20,
      //                       height: 20,
      //                       decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         color: Colors.red,
      //                       ),
      //                     ),
      //                     SizedBox(width: 8),
      //                     Text("Zauzeti termini"),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         SizedBox(height: 8),
      //         Row(
      //           children: [
      //             Text(
      //               'Broj gostiju: ',
      //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //             ),
      //             Expanded(
      //               child: Slider(
      //                 value: _numberOfGuests.toDouble(),
      //                 min: 1,
      //                 max: (widget.jedinica.kapacitet ?? 1).toDouble(),
      //                 divisions: (widget.jedinica.kapacitet ?? 1),
      //                 label: _numberOfGuests.toString(),
      //                 onChanged: (double value) {
      //                   setState(() {
      //                     _numberOfGuests = value.toInt();
      //                   });
      //                 },
      //               ),
      //             ),
      //             Text('$_numberOfGuests'),
      //           ],
      //         ),
      //         SizedBox(height: 8),
      //         Text(
      //           'Napomena (opcionalno):',
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 8),
      //         TextField(
      //           controller: _notesController,
      //           maxLines: 3,
      //           decoration: InputDecoration(
      //             hintText: 'Unesite napomenu',
      //             border: OutlineInputBorder(),
      //             enabledBorder: OutlineInputBorder(
      //               borderSide: BorderSide(
      //                   color: Colors.grey), // Siva boja kada nije fokusiran
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 16),
      //         if (_rangeStart != null && _rangeEnd != null)
      //           Row(
      //             children: [
      //               Text(
      //                 'Ukupna cijena: ',
      //                 style:
      //                     TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //               ),
      //               SizedBox(width: 8),
      //               Text(
      //                 '${_totalPrice.toStringAsFixed(2)} BAM',
      //                 style: TextStyle(
      //                     fontSize: 18,
      //                     fontWeight: FontWeight.bold,
      //                     color: Colors.green),
      //               ),
      //             ],
      //           ),
      //         SizedBox(height: 16),
      //         SizedBox(height: 16),
      //         Center(
      //           child: ElevatedButton(
      //             onPressed: () => _handlePayment(),
      //             child: Text('Plati i rezerviši'),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.jedinica.naziv}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          // SizedBox(height: 8),
          // Text('Kapacitet: ${widget.jedinica.kapacitet} osoba'),
          // SizedBox(height: 8),
          // Text('Cijena: ${widget.jedinica.cijena?.toStringAsFixed(2)} BAM/noć'),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 410,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.now(),
              lastDay: DateTime(2100),
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              selectedDayPredicate: (day) =>
                  isSameDay(_rangeStart, day) || isSameDay(_rangeEnd, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onRangeSelected: (start, end, focusedDay) {
                _onDaySelected(start, end, focusedDay);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  bool isBooked = zauzetiTermini.any((termin) {
                    if (termin.datumPrijave == null ||
                        termin.datumOdjave == null) return false;
                    return termin.datumPrijave != null &&
                        termin.datumOdjave != null &&
                        (day.difference(termin.datumPrijave!).inDays == 0 ||
                            day.difference(termin.datumOdjave!).inDays == 0 ||
                            (day.isAfter(termin.datumPrijave!) &&
                                day.isBefore(termin.datumOdjave!)));
                  });
                  return Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isBooked ? Colors.red : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isBooked ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("Zauzeti termini"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(bool isDesktop) {
    return SizedBox(
      height: isDesktop ? 450 : 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Broj gostiju: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: _numberOfGuests.toDouble(),
                  min: 1,
                  max: (widget.jedinica.kapacitet ?? 1).toDouble(),
                  divisions: (widget.jedinica.kapacitet ?? 1),
                  label: _numberOfGuests.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _numberOfGuests = value.toInt();
                    });
                  },
                ),
              ),
              Text('$_numberOfGuests'),
            ],
          ),
          SizedBox(height: 12),
          isDesktop
              ? Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: isDesktop ? null : 3,
                      expands: isDesktop,
                      decoration: InputDecoration(
                        hintText: "Unesite napomenu(opcionalno)",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // focusedBorder: OutlineInputBorder(
                        //   borderSide: BorderSide.none,
                        //   borderRadius:
                        //       BorderRadius.circular(8.0),
                        // ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: isDesktop ? null : 3,
                    expands: isDesktop,
                    decoration: InputDecoration(
                      hintText: "Unesite napomenu(opcionalno)",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide.none,
                      //   borderRadius:
                      //       BorderRadius.circular(8.0),
                      // ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                    ),
                  ),
                ),
          SizedBox(height: 12),
          Align(
              alignment:
                  isDesktop ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Text(
                'Ukupna cijena: ${_totalPrice.toStringAsFixed(2)} BAM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _handlePayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontSize: 18),
        ),
        child: Text('Plati i rezerviši'),
      ),
    );
  }
}
