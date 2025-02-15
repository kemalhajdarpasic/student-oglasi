import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/models/search_result.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:studentoglasi_mobile/providers/smjestaji_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodation_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/widgets/menu.dart';
import 'package:studentoglasi_mobile/widgets/responsive/accommodation/desktop_accommodations_layout.dart';
import 'package:studentoglasi_mobile/widgets/responsive/accommodation/mobile_accommodations_layout.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_bottom_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';

class AccommodationsScreen extends StatefulWidget {
  const AccommodationsScreen({super.key});

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  late SmjestajiProvider _smjestajiProvider;
  late OcjeneProvider _ocjeneProvider;
  SearchResult<Smjestaj>? smjestaji;
  TextEditingController _nazivController = TextEditingController();
  Map<int, double> _averageRatings = {};
  bool _isLoading = false;
  bool _hasError = false;
  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _smjestajiProvider = context.read<SmjestajiProvider>();
    _ocjeneProvider = context.read<OcjeneProvider>();
    _fetchData(null);
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
        if (_nazivController.text.isNotEmpty) 'naziv': _nazivController.text,
        if (filter != null) ...filter,
      };

      var data = isLoggedIn
          ? await _smjestajiProvider.getAllWithRecommendations(
              studentId: studentId,
              filter: finalFilter,
            )
          : await _smjestajiProvider.get(filter: finalFilter);

      smjestaji?.result.clear();
      _averageRatings.clear();
      setState(() {
        smjestaji = data;
        _averageRatings.clear();

        if (data.result.isEmpty) {
          smjestaji?.result.clear();
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

  Future<void> _fetchAverageRatings() async {
    try {
      for (var smjestaj in smjestaji?.result ?? []) {
        double averageRating = await _ocjeneProvider.getAverageOcjena(
          smjestaj.id!,
          ItemType.accommodation.toShortString(),
        );
        setState(() {
          _averageRatings[smjestaj.id!] = averageRating;
        });
      }
    } catch (error) {
      print("Error fetching average ratings: $error");
    }
  }

  void _onSearchChanged() {
    _fetchData(null);
  }

  void _navigateToDetailsScreen(
      int accommodationId, double averageRating) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccommodationDetailsScreen(
          smjestaj:
              smjestaji!.result.firstWhere((s) => s.id == accommodationId),
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
                  naslovController: _nazivController,
                  onSearchChanged: _onSearchChanged,
                ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !isDesktop && isLoggedIn,
        ),
        drawer: isDesktop || !isLoggedIn ? null : DrawerMenu(),
        body: isDesktop
            ? DesktopAccommodationsLayout(
                smjestaji: smjestaji?.result ?? [],
                averageRatings: _averageRatings,
                onCardTap: _navigateToDetailsScreen,
                onFilterApplied: (filter) => _fetchData(filter),
                totalItems: smjestaji?.count ?? 0,
              )
            : MobileAccommodationsLayout(
                isLoading: _isLoading,
                hasError: _hasError,
                averageRatings: _averageRatings,
                smjestaji: smjestaji?.result ?? [],
                onCardTap: _navigateToDetailsScreen,
                onFilterApplied: (filter) => _fetchData(filter),
              ),
        bottomNavigationBar:
            !isDesktop ? MobileBottomNavigationBar(currentIndex: 3) : null,
      );
    });
  }
}
