import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/SmjestajnaJedinica/smjestajna_jedinica.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/screens/components/reservation_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/widgets/image_gallery.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/widgets/star_rating.dart';

class AccommodationUnitCard extends StatefulWidget {
  final SmjestajnaJedinica jedinica;

  const AccommodationUnitCard({Key? key, required this.jedinica})
      : super(key: key);

  @override
  _AccommodationUnitCardState createState() => _AccommodationUnitCardState();
}

class _AccommodationUnitCardState extends State<AccommodationUnitCard> {
  late Future<double> _averageRating;

  @override
  void initState() {
    super.initState();
    _averageRating = _fetchAverageRating();
  }

  Future<double> _fetchAverageRating() async {
    return await Provider.of<OcjeneProvider>(context, listen: false)
        .getAverageOcjena(
            widget.jedinica.id!, ItemType.accommodationUnit.toShortString());
  }

  void _updateRating() {
    setState(() {
      _averageRating = _fetchAverageRating();
    });
  }

  @override
  Widget build(BuildContext context) {
    var studentiProvider =
        Provider.of<StudentiProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: widget.jedinica.slikes != null &&
                        widget.jedinica.slikes!.isNotEmpty
                    ? ImageGallery(images: widget.jedinica.slikes!)
                    : Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    size: 100, color: Colors.grey),
                                SizedBox(height: 20),
                                Text(
                                  'Nema dostupne slike',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.jedinica.naziv ?? 'Naziv nije dostupan',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.comment, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentsScreen(
                                  postId: widget.jedinica.id!,
                                  postType: ItemType.accommodationUnit,
                                ),
                              ),
                            );
                          },
                        ),
                        LikeButton(
                          itemId: widget.jedinica.id!,
                          itemType: ItemType.accommodationUnit,
                        ),
                      ],
                    ),
                    Text(
                      widget.jedinica.opis ?? 'Nema sadržaja',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        StarRatingWidget(
                          postId: widget.jedinica.id!,
                          postType: ItemType.accommodationUnit,
                          onRatingChanged: () async {
                            _updateRating();
                          },
                          iconSize: 25,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Kapacitet: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '${widget.jedinica.kapacitet ?? 'N/A'} osobe',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        List<Widget> availableServices = [];
                        if (widget.jedinica.kuhinja == true) {
                          availableServices.add(_buildServiceIcon(
                              Icons.kitchen_outlined, 'Kuhinja'));
                        }
                        if (widget.jedinica.tv == true) {
                          availableServices
                              .add(_buildServiceIcon(Icons.tv, 'TV'));
                        }
                        if (widget.jedinica.klimaUredjaj == true) {
                          availableServices.add(
                              _buildServiceIcon(Icons.ac_unit, 'Klima uređaj'));
                        }
                        if (widget.jedinica.terasa == true) {
                          availableServices
                              .add(_buildServiceIcon(Icons.balcony, 'Terasa'));
                        }
                        if (widget.jedinica.dodatneUsluge != null) {
                          for (var usluga
                              in widget.jedinica.dodatneUsluge!.split(',')) {
                            availableServices.add(_buildServiceIcon(
                                Icons.more_horiz, usluga.trim()));
                          }
                        }
                        int half = (availableServices.length / 2).ceil();
                        List<Widget> leftColumn =
                            availableServices.take(3).toList();
                        List<Widget> rightColumn =
                            availableServices.skip(3).take(3).toList();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: leftColumn,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: rightColumn,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.jedinica.cijena?.toStringAsFixed(2) ?? 'N/A'} BAM',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (!studentiProvider.isLoggedIn) {
                              Navigator.of(context).pushNamed('/login');
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationScreen(
                                  jedinica: widget.jedinica,
                                ),
                              ),
                            );
                          },
                          child: Text('Rezerviši'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ]),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 4),
                  FutureBuilder<double>(
                    future: _averageRating,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(strokeWidth: 2);
                      } else if (snapshot.hasError) {
                        return Text("N/A");
                      } else {
                        return Text(
                          snapshot.data != null && snapshot.data! > 0
                              ? snapshot.data!.toStringAsFixed(1)
                              : "N/A",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String name) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
