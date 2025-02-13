import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/models/Objava/objava.dart';
import 'package:studentoglasi_mobile/providers/komentari_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopNewsDetailsLayout extends StatefulWidget {
  final Objava objava;

  const DesktopNewsDetailsLayout({Key? key, required this.objava})
      : super(key: key);

  @override
  State<DesktopNewsDetailsLayout> createState() =>
      _DesktopNewsDetailsLayoutState();
}

class _DesktopNewsDetailsLayoutState extends State<DesktopNewsDetailsLayout> {
  int _commentCount = 0;
  late KomentariProvider _komentariProvider;

  @override
  void initState() {
    super.initState();
    _komentariProvider = KomentariProvider();
    _fetchCommentCount();
  }

  Future<void> _fetchCommentCount() async {
    try {
      int count = await _komentariProvider.fetchCommentCount(
          widget.objava.id!, ItemType.news.toShortString());
      setState(() {
        _commentCount = count;
      });
    } catch (e) {
      print("Error fetching comment count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      'Edukacija': Colors.green.shade400,
      'Ponude i popusti': Colors.blue.shade400,
      'Aktivnosti i događaji': Colors.orange.shade400,
      'Tehnologija': Colors.purple.shade400,
    };

    final categoryName =
        widget.objava.kategorija?.naziv ?? 'Nepoznata kategorija';
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
                        widget.objava.naslov ?? 'Nema naziva',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.objava.kategorija?.naziv ?? 'Nepoznata kategorija',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            categoryColors[widget.objava.kategorija?.naziv] ??
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
                    child: widget.objava.slika != null
                        ? Image.network(
                            FilePathManager.constructUrl(widget.objava.slika!),
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
                      icon: Icon(Icons.comment_outlined, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: widget.objava.id!,
                              postType: ItemType.news,
                            ),
                          ),
                        ).then((_) => _fetchCommentCount());
                      },
                    ),
                    Text(
                      '$_commentCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    LikeButton(
                      itemId: widget.objava.id!,
                      itemType: ItemType.news,
                    ),
                  ],
                ),
                Text(
                  widget.objava.sadrzaj ?? 'Nema opisa',
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
