import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/screens/internship_form_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopInternshipDetailsLayout extends StatelessWidget {
  final Praksa praksa;
  final double averageRating;

  const DesktopInternshipDetailsLayout(
      {Key? key, required this.praksa, required this.averageRating})
      : super(key: key);

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
                        praksa.idNavigation?.naslov ?? 'Nema naziva',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      praksa.organizacija?.naziv ?? 'N/A',
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
                        child: praksa.idNavigation?.slika != null
                            ? Image.network(
                                FilePathManager.constructUrl(
                                    praksa.idNavigation!.slika!),
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
                          mainAxisSize:
                              MainAxisSize.min, 
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 40,
                            ),
                            SizedBox(
                                width: 4), 
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: praksa.id!,
                              postType: ItemType.internship,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    LikeButton(
                      itemId: praksa.id!,
                      itemType: ItemType.internship,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  praksa.idNavigation?.opis ?? 'Nema opisa',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Benefiti',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  praksa.benefiti ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Kvalifikacije',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  praksa.kvalifikacije ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoBox(
                      title: 'Rok prijave',
                      value: praksa.idNavigation?.rokPrijave != null
                          ? DateFormat('dd MM yyyy')
                              .format(praksa.idNavigation!.rokPrijave)
                          : 'Nema datuma',
                    ),
                    _buildInfoBox(
                        title: 'Trajanje',
                        value:
                            '${DateFormat('dd.MM.yyyy').format(praksa.pocetakPrakse!)} - ${DateFormat('dd.MM.yyyy').format(praksa.krajPrakse)}'),
                    _buildInfoBox(
                      title: 'Plaćena',
                      value: praksa.placena == true ? 'Da' : 'Ne',
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
                          builder: (context) => PrijavaPraksaFormScreen(
                            internship: praksa,
                          ),
                        ),
                      );
                    },
                    child: Text('Prijavi se'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), 
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16), 
                      minimumSize: Size(150, 40), 
                      textStyle: TextStyle(
                        fontSize: 16, 
                        fontWeight:
                            FontWeight.bold, 
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
