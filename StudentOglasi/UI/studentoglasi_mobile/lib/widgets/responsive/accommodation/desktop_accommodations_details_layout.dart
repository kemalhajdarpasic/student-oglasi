import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/components/accommodation_unit_card.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/image_viewer.dart';
import 'package:studentoglasi_mobile/widgets/star_rating.dart';

class DesktopAccommodationDetailsLayout extends StatelessWidget {
  final Smjestaj smjestaj;
  final double averageRating;
  final VoidCallback onRatingUpdated;

  const DesktopAccommodationDetailsLayout({
    Key? key,
    required this.smjestaj,
    required this.averageRating,
    required this.onRatingUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var studentiProvider =
        Provider.of<StudentiProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        smjestaj.naziv ?? 'Naziv nije dostupan',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!studentiProvider.isLoggedIn) {
                          Navigator.of(context).pushNamed('/login');
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Ocijenite smještaj',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StarRatingWidget(
                                  postId: smjestaj.id!,
                                  postType: ItemType.accommodation,
                                  onRatingChanged: () {
                                    Navigator.pop(context);
                                    onRatingUpdated();
                                  },
                                  iconSize: 50,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  smjestaj.adresa != null && smjestaj.grad != null
                      ? '${smjestaj.adresa} - ${smjestaj.grad?.naziv}'
                      : smjestaj.adresa ?? 'Lokacija nije dostupna',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 16),
                smjestaj.slikes != null && smjestaj.slikes!.isNotEmpty
                    ? SizedBox(
                        height: 430,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: smjestaj.slikes != null &&
                                        smjestaj.slikes!.isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ImageViewer(
                                              images: smjestaj.slikes!,
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          child: Image.network(
                                            FilePathManager.constructUrl(
                                                smjestaj.slikes!.first.naziv!),
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: double.infinity,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Text(
                                            'Nema dostupne slike',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: List.generate(
                                        2,
                                        (index) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: smjestaj.slikes!.length > index + 1
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            ImageViewer(
                                                          images:
                                                              smjestaj.slikes!,
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(12.0),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            FilePathManager.constructUrl(
                                                                smjestaj.slikes![index + 1].naziv!),
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: Text(
                                                        'Nema slike',
                                                        style: TextStyle(
                                                            color: Colors.grey[600]),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: List.generate(
                                        2,
                                        (index) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: smjestaj.slikes!.length > index + 3
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            ImageViewer(
                                                          images:
                                                              smjestaj.slikes!,
                                                        ),
                                                      );
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(12.0),
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                FilePathManager.constructUrl(
                                                                    smjestaj.slikes![index + 3].naziv!),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        if (index + 3 == 4 && smjestaj.slikes!.length > 5)
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.black54,
                                                              borderRadius:
                                                                  BorderRadius.circular(12.0),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "+${smjestaj.slikes!.length - 5} slika",
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: Text(
                                                        'Nema slike',
                                                        style: TextStyle(
                                                            color: Colors.grey[600]),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            'Nema dostupne slike',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                        ),
                      ),

                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Opis",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                smjestaj.opis ?? 'Nema opisa za smještaj.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 120),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Prosječna ocjena",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 23.0, vertical: 23.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  averageRating == 0.0
                                      ? 'N/A'
                                      : averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 70,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usluge',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final usluge = [
                          {
                            'name': 'WiFi',
                            'available': smjestaj.wiFi,
                            'icon': Icons.wifi
                          },
                          {
                            'name': 'Parking',
                            'available': smjestaj.parking,
                            'icon': Icons.local_parking
                          },
                          {
                            'name': 'Fitness centar',
                            'available': smjestaj.fitnessCentar,
                            'icon': Icons.fitness_center
                          },
                          {
                            'name': 'Restoran',
                            'available': smjestaj.restoran,
                            'icon': Icons.restaurant
                          },
                          {
                            'name': 'Usluge prijevoza',
                            'available': smjestaj.uslugePrijevoza,
                            'icon': Icons.directions_bus
                          },
                        ]
                            .where((usluga) => usluga['available'] == true)
                            .toList();

                        const int itemsPerRow = 5;

                        return Column(
                          children: List.generate(
                            (usluge.length / itemsPerRow).ceil(),
                            (rowIndex) {
                              final start = rowIndex * itemsPerRow;
                              final end =
                                  (start + itemsPerRow).clamp(0, usluge.length);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:
                                    usluge.sublist(start, end).map((usluga) {
                                  return Expanded(
                                    child: Row(
                                      children: [
                                        Icon(usluga['icon'] as IconData,
                                            size: 20),
                                        SizedBox(width: 4),
                                        Text(
                                          usluga['name'] as String,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Smještajne jedinice',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                smjestaj.smjestajnaJedinicas != null &&
                        smjestaj.smjestajnaJedinicas!.isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final double itemWidth =
                              (constraints.maxWidth - 16 * 2) / 3;

                          return Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: smjestaj.smjestajnaJedinicas!
                                .map((jedinica) => SizedBox(
                                      width: itemWidth,
                                      child: AccommodationUnitCard(
                                          jedinica: jedinica),
                                    ))
                                .toList(),
                          );
                        },
                      )
                    : Center(
                        child: Text('Nema dostupnih smještajnih jedinica.'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
