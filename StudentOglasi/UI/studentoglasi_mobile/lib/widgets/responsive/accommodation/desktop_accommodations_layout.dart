import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopAccommodationsLayout extends StatelessWidget {
  final List<Smjestaj> smjestaji;
  final List<Smjestaj> recommendedSmjestaji;
  final Map<int, double> averageRatings;
  final Function(int, double) onCardTap;

  const DesktopAccommodationsLayout({
    Key? key,
    required this.smjestaji,
    required this.recommendedSmjestaji,
    required this.averageRatings,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtriraj',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                    Expanded(
                      flex: 3,
                      child: ListView(
                        children: [
                          if (recommendedSmjestaji.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Preporučeni smještaji',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ...recommendedSmjestaji.map((smjestaj) {
                            final averageRating =
                                averageRatings[smjestaj.id] ?? 0.0;
                            return _buildPostCard(
                                smjestaj, averageRating, true);
                          }).toList(),
                          if (smjestaji.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Ostali smještaji',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ...smjestaji.map((smjestaj) {
                            final averageRating =
                                averageRatings[smjestaj.id] ?? 0.0;
                            return _buildPostCard(
                                smjestaj, averageRating, false);
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(
      Smjestaj smjestaj, double averageRating, bool isRecommended) {
    return InkWell(
      onTap: () {
        onCardTap(smjestaj.id!, averageRating);
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 330,
                  height: 250,
                  decoration: BoxDecoration(
                    image:
                        smjestaj.slikes != null && smjestaj.slikes!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  FilePathManager.constructUrl(
                                      smjestaj.slikes!.first.naziv!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                smjestaj.naziv ?? 'Bez naslova',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      averageRating == 0.0
                                          ? 'N/A'
                                          : averageRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < averageRating.round()
                                    ? Colors.black
                                    : Colors.grey,
                              );
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            smjestaj.grad?.naziv ?? 'Nepoznati grad',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              if (smjestaj.wiFi == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('WiFi'),
                                ),
                              if (smjestaj.parking == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Parking'),
                                ),
                              if (smjestaj.fitnessCentar == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Fitness Centar'),
                                ),
                              if (smjestaj.restoran == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Restoran'),
                                ),
                              if (smjestaj.uslugePrijevoza == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Usluge prijevoza'),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Builder(
                              builder: (context) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsScreen(
                                        postId: smjestaj.id!,
                                        postType: ItemType.accommodation,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            LikeButton(
                              itemId: smjestaj.id!,
                              itemType: ItemType.accommodation,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isRecommended)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'Preporučeno',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
