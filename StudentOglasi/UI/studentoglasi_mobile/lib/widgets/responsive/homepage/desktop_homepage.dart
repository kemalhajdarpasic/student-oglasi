import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentoglasi_mobile/models/Objava/objava.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/screens/news_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:collection/collection.dart';

class DesktopHomepage extends StatelessWidget {
  final objave;

  DesktopHomepage({this.objave});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 600,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: objave != null && objave!.result.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ObjavaDetailsScreen(
                                          objava: objave!.result[0]),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    image: objave!.result[0].slika != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              FilePathManager.constructUrl(
                                                  objave!.result[0].slika!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                objave!.result[0].naslov ??
                                                    "Naslov nedostupan",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.comment_outlined,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentsScreen(
                                                            postId: objave!
                                                                .result[0].id!,
                                                            postType:
                                                                ItemType.news,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Text(
                                                    objave!
                                                        .result[0].brojKomentara
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  LikeButton(
                                                    itemId:
                                                        objave!.result[0].id!,
                                                    itemType: ItemType.news,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                DateFormat('dd.MM.yyyy').format(
                                                    objave!.result[0]
                                                        .vrijemeObjave!),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: double.infinity,
                                color: Colors.blueAccent,
                                child: Center(
                                  child: Text(
                                    "Nema dostupnih obavijesti.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 6,
                              child: objave != null && objave!.result.length > 1
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ObjavaDetailsScreen(
                                                    objava: objave!.result[1]),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          image: objave!.result[1].slika != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    FilePathManager
                                                        .constructUrl(objave!
                                                            .result[1].slika!),
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.greenAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Text(
                                                  objave!.result[1].naslov ??
                                                      "Naslov nedostupan",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.comment_outlined,
                                                              color:
                                                                  Colors.white),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CommentsScreen(
                                                                  postId: objave!
                                                                      .result[1]
                                                                      .id!,
                                                                  postType:
                                                                      ItemType
                                                                          .news,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          objave!.result[1]
                                                              .brojKomentara
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        LikeButton(
                                                          itemId: objave!
                                                              .result[1].id!,
                                                          itemType:
                                                              ItemType.news,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      DateFormat('dd.MM.yyyy')
                                                          .format(objave!
                                                              .result[1]
                                                              .vrijemeObjave!),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.greenAccent,
                                      child: Center(
                                        child: Text(
                                          "Nema dodatnih obavijesti.",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              flex: 4,
                              child: objave != null && objave!.result.length > 2
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ObjavaDetailsScreen(
                                                    objava: objave!.result[2]),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          image: objave!.result[2].slika != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      FilePathManager
                                                          .constructUrl(objave!
                                                              .result[2]
                                                              .slika!)),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.redAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Text(
                                                  objave!.result[2].naslov ??
                                                      "Naslov nedostupan",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.comment_outlined,
                                                              color:
                                                                  Colors.white),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CommentsScreen(
                                                                  postId: objave!
                                                                      .result[2]
                                                                      .id!,
                                                                  postType:
                                                                      ItemType
                                                                          .news,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          objave!.result[2]
                                                              .brojKomentara
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        LikeButton(
                                                          itemId: objave!
                                                              .result[2].id!,
                                                          itemType:
                                                              ItemType.news,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      DateFormat('dd.MM.yyyy')
                                                          .format(objave!
                                                              .result[2]
                                                              .vrijemeObjave!),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.redAccent,
                                      child: Center(
                                        child: Text(
                                          "Nema dodatnih obavijesti.",
                                          style: TextStyle(
                                            color: Colors.white,
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
                ),
                SizedBox(height: 30),
                if (objave != null && objave!.result.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in groupBy(
                              objave!.result,
                              (Objava objava) =>
                                  objava.kategorija?.naziv ?? 'Nepoznato')
                          .entries) ...[
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            entry.value.length,
                            (index) {
                              final objava = entry.value[index];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ObjavaDetailsScreen(
                                                  objava: objava),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        image: objava.slika != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  FilePathManager.constructUrl(
                                                      objava.slika!),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                objava.naslov ??
                                                    "Naslov nedostupan",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('dd.MM.yyyy').format(
                                                    objava.vrijemeObjave!),
                                                style: TextStyle(
                                                  color: Colors.white,
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
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
