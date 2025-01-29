import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Oglas/oglas.dart';
import 'package:studentoglasi_mobile/models/StatusOglas/statusoglasi.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/models/Stipenditor/stipenditor.dart';
import 'package:studentoglasi_mobile/providers/ocjene_provider.dart';
import 'package:studentoglasi_mobile/providers/oglasi_provider.dart';
import 'package:studentoglasi_mobile/providers/statusoglasi_provider.dart';
import 'package:studentoglasi_mobile/providers/stipendije_provider.dart';
import 'package:studentoglasi_mobile/providers/stipenditori_provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/screens/accommodations_screen.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/screens/internships_screen.dart';
import 'package:studentoglasi_mobile/screens/main_screen.dart';
import 'package:studentoglasi_mobile/screens/scholarship_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/scholarship/desktop_scholarships_layout.dart';
import '../models/search_result.dart';
import '../widgets/menu.dart';

class ScholarshipsScreen extends StatefulWidget {
  @override
  _ScholarshipsScreenState createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  late StipendijeProvider _stipendijeProvider;
  late StatusOglasiProvider _statusProvider;
  late StipenditoriProvider _stipenditorProvider;
  late OglasiProvider _oglasiProvider;
  late OcjeneProvider _ocjeneProvider;
  bool _isLoading = true;
  bool _hasError = false;
  Stipenditor? selectedStipenditor;
  SearchResult<Stipendije>? _stipendije;
  SearchResult<Stipenditor>? stipenditoriResult;
  SearchResult<StatusOglasi>? statusResult;
  SearchResult<Oglas>? oglasiResult;
  Map<int, double> _averageRatings = {};
  TextEditingController _naslovController = new TextEditingController();
  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _stipendijeProvider = context.read<StipendijeProvider>();
    _statusProvider = context.read<StatusOglasiProvider>();
    _stipenditorProvider = context.read<StipenditoriProvider>();
    _oglasiProvider = context.read<OglasiProvider>();
    _ocjeneProvider = context.read<OcjeneProvider>();
    _fetchData(null);
    _fetchOglasi();
    _fetchStatusOglasi();
    _fetchStipenditori();
  }

  void _fetchStatusOglasi() async {
    var statusData = await _statusProvider.get();
    setState(() {
      statusResult = statusData;
    });
  }

  void _fetchOglasi() async {
    var oglasData = await _oglasiProvider.get();
    setState(() {
      oglasiResult = oglasData;
    });
  }

  void _fetchStipenditori() async {
    var stipenditoriData = await _stipenditorProvider.get();
    setState(() {
      stipenditoriResult = stipenditoriData;
    });
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

      if (studentId == null) {
        var student = await studentiProvider.getCurrentStudent();
        studentId = student.id;
      }

      if (studentId != null) {
        var finalFilter = {
          'page': currentPage,
          'pageSize': pageSize,
          if (filter != null) ...filter,
        };

        var data = await _stipendijeProvider.getAllWithRecommendations(
          studentId: studentId,
          filter: finalFilter,
        );
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
      } else {
        throw Exception("Student ID is not available");
      }
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
            automaticallyImplyLeading: !isDesktop,
          ),
          drawer: isDesktop ? null : DrawerMenu(),
          body: isDesktop
              ? DesktopScholarshipsLayout(
                  stipendije: _stipendije?.result ?? [],
                  averageRatings: _averageRatings,
                  onCardTap: _navigateToDetailsScreen,
                  onFilterApplied: (filter) => _fetchData(filter),
                  totalItems: _stipendije?.count ?? 0,
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
                                  builder: (context) => ObjavaListScreen(),
                                ),
                              );
                            },
                            child: Text('Početna'),
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
                              : _stipendije?.count == 0
                                  ? Center(
                                      child: Text('Nema dostupnih podataka.'))
                                  : ListView.builder(
                                    itemCount: _stipendije?.result.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final smjestaj = _stipendije!.result[index];
                                      return _buildPostCard(
                                        smjestaj,
                                        isRecommended:
                                            smjestaj.isRecommended ?? false,
                                      );
                                    },
                                  ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPostCard(Stipendije stipendija, {bool isRecommended = false}) {
    final averageRating = _averageRatings[stipendija.id] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: InkWell(
          onTap: () {
            _navigateToDetailsScreen(stipendija.id!, averageRating);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    stipendija.idNavigation?.slika != null
                        ? Image.network(
                            FilePathManager.constructUrl(
                                stipendija.idNavigation!.slika!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                    if (isRecommended)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            'Preporučeno',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  stipendija.idNavigation?.naslov ?? 'Nema naziva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  stipendija.idNavigation?.opis ?? 'Nema sadržaja',
                  style: TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: stipendija.id!,
                              postType: ItemType.scholarship,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.comment, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Komentari'),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    LikeButton(
                      itemId: stipendija.id!,
                      itemType: ItemType.scholarship,
                    ),
                    SizedBox(width: 8),
                    Text('Sviđa mi se'),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(averageRating == 0.0
                            ? 'N/A'
                            : averageRating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
