import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Kategorija/kategorija.dart';
import 'package:studentoglasi_mobile/models/Objava/objava.dart';
import 'package:studentoglasi_mobile/models/search_result.dart';
import 'package:studentoglasi_mobile/providers/objave_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/screens/news_details_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/desktop_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_bottom_nav_bar.dart';
import 'package:studentoglasi_mobile/widgets/responsive/nav_bar/mobile_nav_bar.dart';

class MobileNewsCategoryScreen extends StatefulWidget {
  final Kategorija kategorija;

  MobileNewsCategoryScreen({required this.kategorija});

  @override
  State<MobileNewsCategoryScreen> createState() =>
      _MobileNewsCategoryScreenState();
}

class _MobileNewsCategoryScreenState extends State<MobileNewsCategoryScreen> {
  late ObjaveProvider _objaveProvider;
  SearchResult<Objava>? _objave;
  String? _searchQuery;
  String? _selectedSortOption;
  bool _isLoading = true;
  TextEditingController _naslovController = new TextEditingController();

  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _objaveProvider = context.read<ObjaveProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var data = await _objaveProvider.get(filter: {
        if (widget.kategorija.id != null) 'kategorijaID': widget.kategorija.id,
        'naslov': _naslovController.text,
        if (_selectedSortOption != null) 'sort': _selectedSortOption,
        'page': currentPage,
        'pageSize': pageSize
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
      });
    }
  }

  void _refreshFilteredResults() {
    setState(() {
      _isLoading = true;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: NavBarMobile(
            naslovController: _naslovController,
            onSearchChanged: _refreshFilteredResults,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showSortOptions,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _objave == null || _objave!.result.isEmpty
                      ? Center(child: Text('Trenutno nema dostupnih praksi.'))
                      : ListView.builder(
                          itemCount: _objave!.result.length,
                          itemBuilder: (context, index) {
                            final objava = _objave!.result[index];
                            return _buildPostCard(objava);
                          },
                        ),
            ),
          ],
        ),
        bottomNavigationBar: MobileBottomNavigationBar(currentIndex: 0));
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sortiraj po",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
                children: [
                  _buildSortButton("Najnovije"),
                  _buildSortButton("Najstarije"),
                  _buildSortButton("Popularnost"),
                  _buildSortButton("Naziv A-Z"),
                  _buildSortButton("Naziv Z-A"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortButton(String title) {
    bool isSelected = _selectedSortOption == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedSortOption = title;
          _refreshFilteredResults();
        });
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPostCard(Objava objava) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObjavaDetailsScreen(objava: objava),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    objava.slika != null
                        ? Image.network(
                            FilePathManager.constructUrl(objava.slika!),
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
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  objava.naslov ?? 'Nema naziva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: objava.id!,
                              postType: ItemType.news,
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
                      itemId: objava.id!,
                      itemType: ItemType.news,
                    ),
                    SizedBox(width: 8),
                    Text('Sviđa mi se'),
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Edukacija':
        return Colors.green;
      case 'Ponude i popusti':
        return Colors.blue;
      case 'Aktivnosti i događaji':
        return Colors.orange;
      case 'Tehnologija':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
