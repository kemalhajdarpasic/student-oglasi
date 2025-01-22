import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopScholarshipsLayout extends StatelessWidget {
  final List<Stipendije> stipendije;
  final List<Stipendije> recommendedStipendije;
  final Map<int, double> averageRatings;
  final Function(int, double) onCardTap;

  const DesktopScholarshipsLayout({
    Key? key,
    required this.stipendije,
    required this.recommendedStipendije,
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
                          if (recommendedStipendije.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Preporučene stipendije',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ...recommendedStipendije.map((stipendija) {
                            final averageRating =
                                averageRatings[stipendija.id] ?? 0.0;
                            return _buildPostCard(
                                stipendija, averageRating, true);
                          }).toList(),
                          if (stipendije.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Ostale stipendije',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ...stipendije.map((stipendija) {
                            final averageRating =
                                averageRatings[stipendija.id] ?? 0.0;
                            return _buildPostCard(
                                stipendija, averageRating, false);
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
      Stipendije stipendija, double averageRating, bool isRecommended) {
    return InkWell(
      onTap: () {
        onCardTap(stipendija.id!, averageRating);
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
                    image: stipendija.idNavigation?.slika != null
                        ? DecorationImage(
                            image: NetworkImage(
                              FilePathManager.constructUrl(
                                  stipendija.idNavigation!.slika!),
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
                              Flexible(
                                child: Text(
                                  stipendija.idNavigation?.naslov ??
                                      'Bez naslova',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
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
                            stipendija.stipenditor?.naziv ?? 'Nepoznat',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                            ),
                            child: stipendija.nivoObrazovanja != null &&
                                    stipendija.nivoObrazovanja!.isNotEmpty
                                ? Text(
                                    stipendija.nivoObrazovanja!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(32.0),
                                  ),
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
                                        postId: stipendija.id!,
                                        postType: ItemType.internship,
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
                              itemId: stipendija.id!,
                              itemType: ItemType.internship,
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
