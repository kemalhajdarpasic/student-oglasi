import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:studentoglasi_mobile/models/Objava/objava.dart';
import 'package:studentoglasi_mobile/models/search_result.dart';
import 'package:studentoglasi_mobile/screens/news_details_screen.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/responsive/news/mobile_news_category.dart';

class MobileHomepage extends StatefulWidget {
  final SearchResult<Objava>? objave;
  const MobileHomepage({Key? key, this.objave}) : super(key: key);

  @override
  State<MobileHomepage> createState() => _MobileHomepageState();
}

class _MobileHomepageState extends State<MobileHomepage> {
  int activePage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Objava> objaveList = widget.objave?.result ?? [];
    final List<Objava> topObjave = objaveList.take(3).toList();
    final Map<int, List<Objava>> categorizedObjave =
        _groupByCategory(objaveList.skip(3).toList());
    if (widget.objave == null || widget.objave!.result.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topObjave.isNotEmpty)
            Column(
              children: [
                CarouselSlider.builder(
                  itemCount: topObjave.length,
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    viewportFraction: 0.95,
                    onPageChanged: (index, reason) {
                      setState(() {
                        activePage = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return slider(topObjave[index]);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: indicators(topObjave.length, activePage),
                ),
              ],
            ),
          const SizedBox(height: 16),
          ...categorizedObjave.entries.map((entry) {
            final categoryName =
                entry.value.first.kategorija?.naziv ?? "Nepoznata kategorija";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MobileNewsCategoryScreen(
                                kategorija: entry.value.first.kategorija!,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MobileNewsCategoryScreen(
                                kategorija: entry.value.first.kategorija!,
                              ),
                            ),
                          );
                        },
                        child: Text("Pogledaj sve"),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map((objava) => _buildListItem(objava)).toList(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget slider(Objava objava) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjavaDetailsScreen(objava: objava),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: objava.slika != null
              ? DecorationImage(
                  image: NetworkImage(
                    FilePathManager.constructUrl(objava.slika!),
                  ),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (objava.naslov != null)
                    Text(
                      objava.naslov!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (objava.vrijemeObjave != null)
                    Text(
                      _formatDate(objava.vrijemeObjave!),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(Objava objava) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjavaDetailsScreen(objava: objava),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            objava.slika != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      FilePathManager.constructUrl(objava.slika!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (objava.kategorija?.naziv != null)
                    Text(
                      objava.kategorija!.naziv!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (objava.naslov != null)
                    Text(
                      objava.naslov!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 15),
                  if (objava.vrijemeObjave != null)
                    Text(
                      _formatDate(objava.vrijemeObjave!),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> indicators(int colorsLength, int currentIndex) {
    return List<Widget>.generate(colorsLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: currentIndex == index ? Colors.black : Colors.black26,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }

  Map<int, List<Objava>> _groupByCategory(List<Objava> objave) {
    return {
      for (var objava in objave)
        objava.kategorijaId ?? -1:
            objave.where((o) => o.kategorijaId == objava.kategorijaId).toList(),
    };
  }
}
