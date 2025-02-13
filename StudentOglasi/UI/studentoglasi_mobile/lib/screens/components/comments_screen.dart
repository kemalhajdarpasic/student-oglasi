import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Komenatar/komentar.dart';
import 'package:studentoglasi_mobile/models/Komenatar/komentar_insert.dart';
import 'package:studentoglasi_mobile/providers/komentari_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;
  final ItemType postType;

  const CommentsScreen({
    Key? key,
    required this.postId,
    required this.postType,
  }) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final KomentariProvider _komentariProvider = KomentariProvider();
  List<Komentar> _komentari = [];
  final TextEditingController _commentController = TextEditingController();
  Map<int, bool> _showReplies = {};
  Map<int, TextEditingController> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      List<Komentar> comments = await _komentariProvider.getCommentsByPost(
          widget.postId, widget.postType.toShortString());
      setState(() {
        _komentari = comments;
        _showReplies = {for (var comment in comments) comment.id: false};
        _replyControllers = {
          for (var comment in comments) comment.id: TextEditingController()
        };
      });
    } catch (e) {
      print("Failed to load comments: $e");
    }
  }

  Future<void> _addComment(String text, {int? parentKomentarId}) async {
    try {
      var currentStudent =
          Provider.of<StudentiProvider>(context, listen: false).currentStudent;
      if (currentStudent == null || currentStudent.id == null) {
        throw Exception("Current student or student ID is null");
      }
      KomentarInsert newComment = KomentarInsert(
          widget.postId,
          widget.postType.toShortString(),
          parentKomentarId,
          currentStudent.id!,
          text);

      await _komentariProvider.insertComment(newComment);
      _commentController.clear();
      await _loadComments();

      if (parentKomentarId != null) {
        setState(() {
          _showReplies[parentKomentarId] = true;
        });
      }
    } catch (e) {
      print("Failed to add comment: $e");
    }
  }

  Widget _buildComment(Komentar komentar, {int depth = 0}) {
    var formattedTime = komentar.vrijemeObjave != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(komentar.vrijemeObjave!)
        : 'N/A';

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 8.0),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${komentar.ime} ${komentar.prezime} • $formattedTime',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(komentar.text),
              SizedBox(height: 4.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showReplies[komentar.id] = !_showReplies[komentar.id]!;
                  });
                },
                child: Text(_showReplies[komentar.id]!
                    ? 'Sakrij odgovore'
                    : 'Odgovori (${komentar.odgovori.length})'),
              ),
              if (_showReplies[komentar.id]! && komentar.odgovori.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: komentar.odgovori.map((reply) {
                    var replyFormattedTime = reply.vrijemeObjave != null
                        ? DateFormat('dd.MM.yyyy HH:mm')
                            .format(reply.vrijemeObjave!)
                        : 'N/A';

                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${reply.ime} ${reply.prezime} • $replyFormattedTime',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.0),
                              Text(reply.text),
                              SizedBox(height: 4.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (_showReplies[komentar.id]!)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MediaQuery.of(context).size.width > 800
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _replyControllers[komentar.id],
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: "Unesite svoj odgovor",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _replyControllers[komentar.id]?.clear();
                                  },
                                  child: Text("Otkaži"),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _addComment(
                                        _replyControllers[komentar.id]!.text,
                                        parentKomentarId: komentar.id);
                                  },
                                  child: Text("Pošalji"),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyControllers[komentar.id],
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "Unesite svoj odgovor",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                _addComment(
                                    _replyControllers[komentar.id]!.text,
                                    parentKomentarId: komentar.id);
                              },
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komentari'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 800 ? 1000 : double.infinity;

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _komentari.length,
                        itemBuilder: (context, index) {
                          return _buildComment(_komentari[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MediaQuery.of(context).size.width > 800
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextField(
                                  controller: _commentController,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Unesite svoj komentar",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _commentController.clear();
                                      },
                                      child: Text("Otkaži"),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        _addComment(_commentController.text);
                                      },
                                      child: Text("Pošalji"),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText: "Unesite svoj komentar",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 16.0),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    _addComment(_commentController.text);
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
