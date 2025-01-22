import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/models/Objava/objava.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopNewsDetailsLayout extends StatelessWidget {
  final Objava objava;

  const DesktopNewsDetailsLayout({Key? key, required this.objava})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      'Edukacija': Colors.green.shade400,
      'Ponude i popusti': Colors.blue.shade400,
      'Aktivnosti i događaji': Colors.orange.shade400,
      'Tehnologija': Colors.purple.shade400,
    };

    final categoryName = objava.kategorija?.naziv ?? 'Nepoznata kategorija';
    final categoryColor = categoryColors[categoryName] ?? Colors.grey.shade400;

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
                        objava.naslov ?? 'Nema naziva',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      objava.kategorija?.naziv ?? 'Nepoznata kategorija',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: categoryColors[objava.kategorija?.naziv] ??
                            Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: objava.slika != null
                        ? Image.network(
                            FilePathManager.constructUrl(objava.slika!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: Text(
                                'Nema dostupne slike',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment,
                          color: Colors.blue), 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: objava.id!,
                              postType: ItemType.news,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    LikeButton(
                      itemId: objava.id!,
                      itemType: ItemType.news,
                    ),
                  ],
                ),
                Text(
                  objava.sadrzaj ?? 'Nema opisa',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
