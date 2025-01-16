import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/providers/like_provider.dart';
import 'package:studentoglasi_mobile/providers/objave_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodations_screen.dart';
import 'package:studentoglasi_mobile/screens/internships_screen.dart';
import 'package:studentoglasi_mobile/screens/news_details_screen.dart';
import 'package:studentoglasi_mobile/widgets/responsive/homepage/desktop_homepage.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/screens/scholarships_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';
import '../models/Kategorija/kategorija.dart';
import '../models/Objava/objava.dart';
import '../providers/kategorije_provider.dart';
import '../models/search_result.dart';
import '../widgets/menu.dart';

class ObjavaListScreen extends StatefulWidget {
  @override
  _ObjavaListScreenState createState() => _ObjavaListScreenState();
}

class _ObjavaListScreenState extends State<ObjavaListScreen> {
  late ObjaveProvider _objaveProvider;
  late KategorijaProvider _kategorijeProvider;
  late LikeProvider _likeProvider;
  Kategorija? selectedKategorija;
  bool _isLoading = true;
  bool _hasError = false;
  SearchResult<Objava>? _objave;
  SearchResult<Kategorija>? kategorijeResult;
  TextEditingController _naslovController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    _objaveProvider = context.read<ObjaveProvider>();
    _kategorijeProvider = context.read<KategorijaProvider>();
    _likeProvider = context.read<LikeProvider>();
    _fetchData();
    _fetchKategorije();
    _fetchLikes();
  }

  Future<void> _fetchData() async {
    try {
      var data = await _objaveProvider.get(filter: {
        'naslov': _naslovController.text,
        'kategorijaID': selectedKategorija?.id,
      });
      setState(() {
        _objave = data;
        _isLoading = false;
      });
      print("Data fetched successfully: ${_objave?.count} items.");
    } catch (error) {
      print("Error fetching data");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _fetchKategorije() async {
    var kategorijeData = await _kategorijeProvider.get();
    setState(() {
      kategorijeResult = kategorijeData;
    });
  }

  Future<void> _fetchLikes() async {
    await _likeProvider.getUserLikes();
    await _likeProvider.getAllLikesCount();
  }

  void _onSearchChanged() {
    setState(() {
      _isLoading = true;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 900;

      return Scaffold(
        appBar: AppBar(
          title: isDesktop
              ? NavbarDesktop()
               : NavBarMobile (
              naslovController: _naslovController,
              onSearchChanged: _onSearchChanged,
            ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !isDesktop,
        ),
        drawer: isDesktop ? null : DrawerMenu(),
        body: isDesktop
          ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DesktopHomepage(objave: _objave),
          )
          : Column(
          children: [
            if (!isDesktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScholarshipsScreen(),
                        ),
                      );
                    },
                    child: Text('Stipendije'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipsScreen(),
                        ),
                      );
                    },
                    child: Text('Prakse'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccommodationsScreen(),
                        ),
                      );
                    },
                    child: Text('Smještaj'),
                  ),
                ],
              ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Text(
                              'Neuspješno učitavanje podataka. Molimo pokušajte opet.'))
                      : _objave?.count == 0
                          ? Center(child: Text('Nema dostupnih podataka.'))
                          : ListView.builder(
                              itemCount: _objave?.count,
                              itemBuilder: (context, index) {
                                final objava = _objave!.result[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Card(
                                    child: InkWell(
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            objava.slika != null
                                                ? Image.network(
                                                    FilePathManager
                                                        .constructUrl(
                                                            objava.slika!),
                                                    height: 200,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: double.infinity,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.image,
                                                          size: 100,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(
                                                          'Nema dostupne slike',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            SizedBox(height: 8),
                                            Text(
                                              objava.naslov ?? 'Bez naslova',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              objava.sadrzaj ?? 'Nema sadržaja',
                                              style: TextStyle(fontSize: 16),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.comment,
                                                    color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('Komentari'),
                                                SizedBox(width: 16),
                                                LikeButton(
                                                  itemId: objava.id!,
                                                  itemType: ItemType.news,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Sviđa mi se'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      );
    });
  }
}
