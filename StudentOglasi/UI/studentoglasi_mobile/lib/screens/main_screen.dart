import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/providers/like_provider.dart';
import 'package:studentoglasi_mobile/providers/objave_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodations_screen.dart';
import 'package:studentoglasi_mobile/screens/internships_screen.dart';
import 'package:studentoglasi_mobile/screens/news_details_screen.dart';
import 'package:studentoglasi_mobile/widgets/responsive/homepage/desktop_homepage.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/screens/scholarships_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/responsive/homepage/mobile_homepage.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_bottom_nav_bar.dart';
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
  int _currentTabIndex = 0;
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
      var studentiProvider =
          Provider.of<StudentiProvider>(context, listen: false);
      final bool isLoggedIn = studentiProvider.isLoggedIn;

      return Scaffold(
        appBar: AppBar(
          title: isDesktop
              ? NavbarDesktop()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 52.0), 
                  child: Text(
                    'StudentOglasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !isDesktop,
        ),
        drawer: isDesktop
            ? null
            : DrawerMenu(
                isLoggedIn: isLoggedIn,
              ),
        body: isDesktop
            ? Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: DesktopHomepage(objave: _objave),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: MobileHomepage(objave: _objave),
              ),
        bottomNavigationBar: !isDesktop
            ? MobileBottomNavigationBar(currentIndex: _currentTabIndex)
            : null,
      );
    });
  }
}
