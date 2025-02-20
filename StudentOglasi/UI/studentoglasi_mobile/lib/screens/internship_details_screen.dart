import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import 'package:studentoglasi_mobile/providers/prakse_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/screens/internship_form_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/widgets/responsive/internship/desktop_internship_details_layout.dart';
import 'package:studentoglasi_mobile/widgets/star_rating.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:provider/provider.dart';

class InternshipDetailsScreen extends StatefulWidget {
  final Praksa internship;
  final double averageRating;

  const InternshipDetailsScreen({
    Key? key,
    required this.internship,
    required this.averageRating,
  }) : super(key: key);

  @override
  _InternshipDetailsScreenState createState() =>
      _InternshipDetailsScreenState();
}

class _InternshipDetailsScreenState extends State<InternshipDetailsScreen> {
  late double _averageRating;
  late OcjeneProvider _ocjeneProvider;
  late PraksaProvider _prakseProvider;
  Praksa? praksa;

  @override
  void initState() {
    super.initState();
    _prakseProvider = context.read<PraksaProvider>();
    _averageRating = widget.averageRating;
    _ocjeneProvider = Provider.of<OcjeneProvider>(context, listen: false);
    _fetchPraksa();
  }

  void _fetchPraksa() async {
    try {
      var statusData = await _prakseProvider.getById(widget.internship.id!);
      setState(() {
        praksa = statusData;
      });
    } catch (error) {
      print("Error fetching praksa: $error");
    }
  }

  Future<void> _fetchAverageRatings() async {
    try {
      double newAverageRating = await _ocjeneProvider.getAverageOcjena(
        widget.internship.id!,
        ItemType.internship.toShortString(),
      );
      setState(() {
        _averageRating = newAverageRating;
      });
    } catch (error) {
      print("Error fetching average ratings: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var studentiProvider =
        Provider.of<StudentiProvider>(context, listen: false);

    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 900;
      return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.internship.idNavigation?.naslov ?? 'Detalji prakse'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: isDesktop
            ? Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: DesktopInternshipDetailsLayout(
                  praksa: widget.internship,
                  averageRating: _averageRating,
                  onRatingUpdated: _fetchAverageRatings,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          widget.internship.idNavigation?.slika != null
                              ? Image.network(
                                  FilePathManager.constructUrl(
                                      widget.internship.idNavigation!.slika!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Nema dostupne slike',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!studentiProvider.isLoggedIn) {
                                  Navigator.of(context).pushNamed('/login');
                                  return;
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Ocijenite praksu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        StarRatingWidget(
                                          postId: widget.internship.id!,
                                          postType: ItemType.internship,
                                          onRatingChanged: _fetchAverageRatings,
                                          iconSize: 45,
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Loše',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                )),
                                            Text('Odlično',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.star_rate, color: Colors.white),
                              label: Text(
                                'Ocijeni',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentsScreen(
                                    postId: widget.internship.id!,
                                    postType: ItemType.internship,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          LikeButton(
                            itemId: widget.internship.id!,
                            itemType: ItemType.internship,
                          ),
                          Spacer(),
                          SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  _averageRating > 0
                                      ? _averageRating.toStringAsFixed(1)
                                      : "N/A",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                          '${widget.internship.idNavigation?.naslov ?? 'Nema naslova'}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          '${widget.internship.idNavigation?.opis ?? 'Nema opisa'}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 25),
                      Text(
                        'Pogodnosti i zahtjevi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Organizacija: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${praksa?.organizacija?.naziv ?? 'Nema dostupnog naziva organizacije'}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Placena:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          praksa?.placena == true
                              ? Icon(Icons.check, size: 24)
                              : Icon(Icons.close, size: 24),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Benefiti',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${praksa?.benefiti ?? 'Nema benefita'}'),
                      SizedBox(height: 8),
                      Text('Kvalifikacije',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${praksa?.kvalifikacije ?? 'Nema kvalifikacija'}'),
                      SizedBox(height: 25),
                      Text(
                        'Rok prijave i početak prakse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          Text(
                            'Trajanje prakse: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${DateFormat('dd.MM.yyyy').format(praksa!.pocetakPrakse!)} - ${DateFormat('dd.MM.yyyy').format(praksa!.krajPrakse)}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Rok prijave: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.internship.idNavigation?.rokPrijave != null ? DateFormat('dd MM yyyy').format(widget.internship.idNavigation!.rokPrijave) : 'Nema dostupnog datuma'}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!studentiProvider.isLoggedIn) {
                              Navigator.of(context).pushNamed('/login');
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrijavaPraksaFormScreen(
                                  internship: widget.internship,
                                ),
                              ),
                            );
                          },
                          child: Text('Prijavi se'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
