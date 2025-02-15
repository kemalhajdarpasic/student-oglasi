import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:studentoglasi_mobile/providers/prakse_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/internship_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/widgets/responsive/internship/desktop_internships_layout.dart';
import 'package:studentoglasi_mobile/widgets/responsive/internship/mobile_internships_layout.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_bottom_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';
import '../models/search_result.dart';
import '../widgets/menu.dart';

class InternshipsScreen extends StatefulWidget {
  @override
  _InternshipsScreenState createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  late PraksaProvider _prakseProvider;
  late OcjeneProvider _ocjeneProvider;
  bool _isLoading = true;
  bool _hasError = false;
  SearchResult<Praksa>? _praksa;
  Map<int, double> _averageRatings = {};
  TextEditingController _naslovController = new TextEditingController();
  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _prakseProvider = context.read<PraksaProvider>();
    _ocjeneProvider = context.read<OcjeneProvider>();
    _fetchData(null);
  }

  Future<void> _fetchAverageRatings() async {
    try {
      for (var praksa in _praksa?.result ?? []) {
        double averageRating = await _ocjeneProvider.getAverageOcjena(
          praksa.id!,
          ItemType.internship.toShortString(),
        );
        setState(() {
          _averageRatings[praksa.id!] = averageRating;
        });
      }
    } catch (error) {
      print("Error fetching average ratings: $error");
    }
  }

  Future<void> _fetchData(dynamic filter) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      var studentiProvider =
          Provider.of<StudentiProvider>(context, listen: false);
      var studentId = studentiProvider.currentStudent?.id;
      bool isLoggedIn = studentId != null;

        var finalFilter = {
          'page': currentPage,
          'pageSize': pageSize,
          if (_naslovController.text.isNotEmpty) 'naslov': _naslovController.text,
          if (filter != null) ...filter,
        };

        var data = isLoggedIn ? await _prakseProvider.getAllWithRecommendations(
          studentId: studentId,
          filter: finalFilter,
        ) : await _prakseProvider.get(filter: finalFilter);

        _praksa?.result.clear();
        _averageRatings.clear();
        setState(() {
          _praksa = data;
          _averageRatings.clear();

          if (data.result.isEmpty) {
            _praksa?.result.clear();
          }
          _isLoading = false;
        });

        await _fetchAverageRatings();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _isLoading = true;
    });
    _fetchData(null);
  }

  void _navigateToDetailsScreen(int internshipId, double averageRating) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternshipDetailsScreen(
          internship: _praksa!.result.firstWhere((p) => p.id == internshipId),
          averageRating: averageRating,
        ),
      ),
    );

    if (shouldRefresh == true) {
      _fetchAverageRatings();
    }
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
              : NavBarMobile(
                  naslovController: _naslovController,
                  onSearchChanged: _onSearchChanged,
                ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !isDesktop && isLoggedIn,
        ),
        drawer: isDesktop || !isLoggedIn ? null : DrawerMenu(),
        body: isDesktop
            ? DesktopInternshipsLayout(
                prakse: _praksa?.result ?? [],
                averageRatings: _averageRatings,
                onCardTap: _navigateToDetailsScreen,
                onFilterApplied: (filter) => _fetchData(filter),
                totalItems: _praksa?.count ?? 0,
              )
            : MobileInternshipsLayout(
                isLoading: _isLoading,
                hasError: _hasError,
                averageRatings: _averageRatings,
                prakse: _praksa?.result ?? [],
                onCardTap: _navigateToDetailsScreen,
                onFilterApplied: (filter) => _fetchData(filter),
              ),
        bottomNavigationBar:
            !isDesktop ? MobileBottomNavigationBar(currentIndex: 2) : null,
      );
    });
  }
}
