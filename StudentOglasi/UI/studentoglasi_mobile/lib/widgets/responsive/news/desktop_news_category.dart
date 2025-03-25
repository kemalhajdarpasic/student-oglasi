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

class DesktopNewsCategoryScreen extends StatefulWidget {
  final Kategorija kategorija;

  DesktopNewsCategoryScreen({required this.kategorija});

  @override
  State<DesktopNewsCategoryScreen> createState() =>
      _DesktopNewsCategoryScreenState();
}

class _DesktopNewsCategoryScreenState extends State<DesktopNewsCategoryScreen> {
  late ObjaveProvider _objaveProvider;
  SearchResult<Objava>? _objave;
  String? _searchQuery;
  String? _selectedSortOption;
  bool _isLoading = true;

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
        if (_searchQuery != null && _searchQuery!.isNotEmpty)
          'naslov': _searchQuery,
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
      appBar: AppBar(title: NavbarDesktop(), automaticallyImplyLeading: false),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                              _refreshFilteredResults();
                            },
                            decoration: InputDecoration(
                              hintText: "Pretraži...",
                              prefixIcon: Icon(Icons.search),
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
                        const SizedBox(width: 8.0),
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              _selectedSortOption = value;
                            });
                            _refreshFilteredResults();
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                                value: 'Popularnost',
                                child: Text('Popularnost')),
                            PopupMenuItem(
                                value: 'Najnovije', child: Text('Najnovije')),
                            PopupMenuItem(
                                value: 'Najstarije', child: Text('Najstarije')),
                            PopupMenuItem(
                                value: 'Naziv A-Z', child: Text('Naziv A-Z')),
                            PopupMenuItem(
                                value: 'Naziv Z-A', child: Text('Naziv Z-A')),
                          ],
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.sort, color: Colors.black),
                                const SizedBox(width: 4.0),
                                Text(
                                  _selectedSortOption ?? 'Sortiraj po',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                if (_selectedSortOption != null) ...[
                                  const SizedBox(width: 8.0),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedSortOption = null;
                                      });
                                      _refreshFilteredResults();
                                    },
                                    child: Icon(Icons.close, size: 20),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _objave == null || _objave!.result.isEmpty
                            ? Center(
                                child: Text("Nema objava za ovu kategoriju"))
                            : ListView.builder(
                                itemCount: _objave!.result.length,
                                itemBuilder: (context, index) {
                                  final objava = _objave!.result[index];
                                  return _buildPostCard(objava);
                                },
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: NumberPaginator(
                      numberPages: (((_objave?.count ?? 0) / pageSize).ceil())
                          .clamp(1, double.infinity)
                          .toInt(),
                      onPageChange: (int index) {
                        setState(() {
                          currentPage = index + 1;
                        });
                        _refreshFilteredResults();
                      },
                      initialPage: currentPage - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Objava objava) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjavaDetailsScreen(objava: objava),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 330,
                  height: 250,
                  decoration: BoxDecoration(
                    image: objava.slika != null
                        ? DecorationImage(
                            image: NetworkImage(
                              FilePathManager.constructUrl(objava.slika!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      objava.naslov ?? 'Bez naslova',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                              objava.kategorija?.naziv)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      objava.kategorija?.naziv ??
                                          'Bez kategorije',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getCategoryColor(
                                            objava.kategorija?.naziv),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              SizedBox(
                                height: 100, 
                                child: Text(
                                  objava.sadrzaj ?? 'Bez opisa',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Builder(
                                builder: (context) => InkWell(
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              LikeButton(
                                itemId: objava.id!,
                                itemType: ItemType.news,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
