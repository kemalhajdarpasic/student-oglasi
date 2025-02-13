import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/screens/scholarship_form_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/widgets/star_rating.dart';

class DesktopScholarshipDetailsLayout extends StatelessWidget {
  final Stipendije stipendija;
  final double averageRating;
  final VoidCallback onRatingUpdated;

  const DesktopScholarshipDetailsLayout({
    Key? key,
    required this.stipendija,
    required this.averageRating,
    required this.onRatingUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1050),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stipendija.idNavigation?.naslov ?? 'Nema naziva',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      stipendija.stipenditor?.naziv ?? 'N/A',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: stipendija.idNavigation?.slika != null
                            ? Image.network(
                                FilePathManager.constructUrl(
                                    stipendija.idNavigation!.slika!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: Text(
                                    'Nema dostupne slike',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 40,
                            ),
                            SizedBox(width: 4),
                            Text(
                              averageRating == 0.0
                                  ? 'N/A'
                                  : averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.comment, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentsScreen(
                                  postId: stipendija.id!,
                                  postType: ItemType.scholarship,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        LikeButton(
                          itemId: stipendija.id!,
                          itemType: ItemType.scholarship,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Ocijenite stipendiju',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StarRatingWidget(
                                  postId: stipendija.id!,
                                  postType: ItemType.scholarship,
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
                SizedBox(height: 16),
                Text(
                  stipendija.idNavigation?.opis ?? 'Nema opisa',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Uslovi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  stipendija.uslovi ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Kriterij',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  stipendija.kriterij ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Potrebna dokumentacija',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  stipendija.potrebnaDokumentacija ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Nivo obrazovanja',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  stipendija.nivoObrazovanja ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Izvor',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  stipendija.izvor ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoBox(
                      title: 'Rok prijave',
                      value: stipendija.idNavigation?.rokPrijave != null
                          ? DateFormat('dd.MM.yyyy')
                              .format(stipendija.idNavigation!.rokPrijave)
                          : 'Nema datuma',
                    ),
                    _buildInfoBox(
                      title: 'Iznos',
                      value: stipendija.iznos != null
                          ? '${stipendija.iznos} KM'
                          : 'N/A',
                    ),
                    _buildInfoBox(
                      title: 'Broj stipendista',
                      value: stipendija.brojStipendisata != null
                          ? stipendija.brojStipendisata.toString()
                          : 'N/A',
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrijavaStipendijaFormScreen(
                            scholarship: stipendija,
                          ),
                        ),
                      );
                    },
                    child: Text('Prijavi se'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      minimumSize: Size(150, 40),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String title, required String value}) {
    return Expanded(
      child: Container(
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
