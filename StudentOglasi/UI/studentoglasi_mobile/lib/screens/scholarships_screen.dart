import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/models/Stipenditor/stipenditor.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:studentoglasi_mobile/providers/stipendije_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/scholarship_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_bottom_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/scholarship/desktop_scholarships_layout.dart';
import 'package:studentoglasi_mobile/widgets/responsive/scholarship/mobile_scholarships_layout.dart';
import '../models/search_result.dart';
import '../widgets/menu.dart';

class ScholarshipsScreen extends StatefulWidget {
  @override
  _ScholarshipsScreenState createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  late StipendijeProvider _stipendijeProvider;
  late OcjeneProvider _ocjeneProvider;
  bool _isLoading = true;
  bool _hasError = false;
  Stipenditor? selectedStipenditor;
  SearchResult<Stipendije>? _stipendije;
  Map<int, double> _averageRatings = {};
  TextEditingController _naslovController = new TextEditingController();
  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _stipendijeProvider = context.read<StipendijeProvider>();
    _ocjeneProvider = context.read<OcjeneProvider>();
    _fetchData(null);
  }

  Future<void> _fetchAverageRatings() async {
    try {
      for (var stipendija in _stipendije?.result ?? []) {
        double averageRating = await _ocjeneProvider.getAverageOcjena(
          stipendija.id!,
          ItemType.scholarship.toShortString(),
        );
        setState(() {
          _averageRatings[stipendija.id!] = averageRating;
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

      var data = isLoggedIn
          ? await _stipendijeProvider.getAllWithRecommendations(
              studentId: studentId,
              filter: finalFilter,
            )
          : await _stipendijeProvider.get(filter: finalFilter);

      _stipendije?.result.clear();
      _averageRatings.clear();
      setState(() {
        _stipendije = data;
        _averageRatings.clear();

        if (data.result.isEmpty) {
          _stipendije?.result.clear();
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

  void _navigateToDetailsScreen(int scholarshipId, double averageRating) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScholarshipDetailsScreen(
          scholarship:
              _stipendije!.result.firstWhere((s) => s.id == scholarshipId),
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
    return LayoutBuilder(
      builder: (context, constraints) {
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
              ? DesktopScholarshipsLayout(
                  stipendije: _stipendije?.result ?? [],
                  averageRatings: _averageRatings,
                  onCardTap: _navigateToDetailsScreen,
                  onFilterApplied: (filter) => _fetchData(filter),
                  totalItems: _stipendije?.count ?? 0,
                )
              : MobileScholarshipsLayout(
                  isLoading: _isLoading,
                  hasError: _hasError,
                  averageRatings: _averageRatings,
                  stipendije: _stipendije?.result ?? [],
                  onCardTap: _navigateToDetailsScreen,
                  onFilterApplied: (filter) => _fetchData(filter),
                ),
          bottomNavigationBar:
              !isDesktop ? MobileBottomNavigationBar(currentIndex: 1) : null,
        );
      },
    );
  }
}
