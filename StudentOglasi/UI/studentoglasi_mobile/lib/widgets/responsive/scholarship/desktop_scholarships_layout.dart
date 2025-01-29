import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Grad/grad.dart';
import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/models/Stipenditor/stipenditor.dart';
import 'package:studentoglasi_mobile/providers/gradovi_provider.dart';
import 'package:studentoglasi_mobile/providers/stipenditori_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class DesktopScholarshipsLayout extends StatefulWidget {
  final List<Stipendije> stipendije;
  final Map<int, double> averageRatings;
  final Function(int, double) onCardTap;
  final void Function(dynamic filter) onFilterApplied;
  final int totalItems;

  const DesktopScholarshipsLayout({
    Key? key,
    required this.stipendije,
    required this.averageRatings,
    required this.onCardTap,
    required this.onFilterApplied,
    required this.totalItems,
  }) : super(key: key);

  @override
  State<DesktopScholarshipsLayout> createState() =>
      _DesktopScholarshipsLayoutState();
}

class _DesktopScholarshipsLayoutState extends State<DesktopScholarshipsLayout> {
  List<Grad> gradovi = [];
  List<Stipenditor> stipenditori = [];
  List<int> selectedRatings = [];
  double? selectedRating;
  int? selectedGradId;
  String? searchQuery;
  String? selectedSortOption;
  int? selectedStipenditorId;

  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final gradoviProvider =
        Provider.of<GradoviProvider>(context, listen: false);
    final stipenditoriProvider =
        Provider.of<StipenditoriProvider>(context, listen: false);

    final gradoviResult = await gradoviProvider.get();
    final stipenditoriResult = await stipenditoriProvider.get();

    setState(() {
      gradovi = gradoviResult.result;
      stipenditori = stipenditoriResult.result;
    });
  }

  Map<String, dynamic> generateFilter() {
    return {
      if (selectedGradId != null) 'GradID': selectedGradId,
      if (selectedStipenditorId != null) 'StipenditorID': selectedStipenditorId,
      if (selectedRatings.isNotEmpty) 'ProsjecneOcjene': selectedRatings,
      if (searchQuery != null && searchQuery!.isNotEmpty) 'naslov': searchQuery,
      if (selectedSortOption != null) 'sort': selectedSortOption,
      'page': currentPage,
      'pageSize': pageSize
    };
  }

  bool hasActiveFilters() {
    return selectedGradId != null ||
        selectedStipenditorId != null ||
        selectedRatings.isNotEmpty ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        selectedSortOption != null;
  }

  Future<void> _refreshFilteredResults() async {
    var filter = generateFilter();
    widget.onFilterApplied(filter);
  }

  List<Widget> _buildStipendijeList() {
    if (widget.stipendije.isEmpty) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Text(
              'Nema dostupnih stipendija.',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    final recommendedStipendije =
        widget.stipendije.where((p) => p.isRecommended == true).toList();
    final otherStipendije =
        widget.stipendije.where((p) => p.isRecommended != true).toList();

    bool shouldShowSingleList =
        selectedSortOption != null || recommendedStipendije.isEmpty;

    if (shouldShowSingleList) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Stipendije',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      widgets.addAll(widget.stipendije.map((stipendija) {
        final averageRating = widget.averageRatings[stipendija.id] ?? 0.0;
        return _buildPostCard(
            stipendija, averageRating, stipendija.isRecommended ?? false);
      }).toList());
    } else {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Preporučene stipendije',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      widgets.addAll(recommendedStipendije.map((stipendija) {
        final averageRating = widget.averageRatings[stipendija.id] ?? 0.0;
        return _buildPostCard(stipendija, averageRating, true);
      }).toList());

      if (otherStipendije.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ostale stipendije',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );

        widgets.addAll(otherStipendije.map((stipendija) {
          final averageRating = widget.averageRatings[stipendija.id] ?? 0.0;
          return _buildPostCard(stipendija, averageRating, false);
        }).toList());
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: Container(
              color: Colors.grey[100],
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 16.0, right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filtriraj',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasActiveFilters())
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedRatings.clear();
                                        selectedGradId = null;
                                        selectedStipenditorId = null;
                                        _refreshFilteredResults();
                                      });
                                    },
                                    child: Text(
                                      'Resetiraj sve',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Prosječna ocjena',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedRatings.isNotEmpty)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedRatings.clear();
                                                  _refreshFilteredResults();
                                                });
                                              },
                                              child: Text(
                                                'Resetiraj',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                        ],
                                      ),
                                      children: [
                                        Column(
                                          children: List.generate(5, (index) {
                                            int rating = 5 - index;
                                            return Row(
                                              children: [
                                                Checkbox(
                                                  value: selectedRatings
                                                      .contains(rating),
                                                  onChanged: (isChecked) {
                                                    setState(() {
                                                      if (isChecked == true) {
                                                        selectedRatings
                                                            .add(rating);
                                                      } else {
                                                        selectedRatings
                                                            .remove(rating);
                                                      }
                                                      _refreshFilteredResults();
                                                    });
                                                  },
                                                ),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (starIndex) => Icon(
                                                      starIndex < rating
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      size: 21,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Stipenditori',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedStipenditorId != null)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedStipenditorId = null;
                                                  _refreshFilteredResults();
                                                });
                                              },
                                              child: Text(
                                                'Resetiraj',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                        ],
                                      ),
                                      children:
                                          stipenditori.map((organizacija) {
                                        return ListTile(
                                          title: Text(organizacija.naziv ?? ''),
                                          leading: Radio<int>(
                                            value: organizacija.id!,
                                            groupValue: selectedStipenditorId,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedStipenditorId = value;
                                                _refreshFilteredResults();
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 8),
                                    ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Grad',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedGradId != null)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedGradId = null;
                                                  _refreshFilteredResults();
                                                });
                                              },
                                              child: Text(
                                                'Resetiraj',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                        ],
                                      ),
                                      children: gradovi.map((grad) {
                                        return ListTile(
                                          title: Text(grad.naziv ?? ''),
                                          leading: Radio<int>(
                                            value: grad.id!,
                                            groupValue: selectedGradId,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedGradId = value;
                                                _refreshFilteredResults();
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                    Expanded(
                      flex: 3,
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
                                        searchQuery = value;
                                      });
                                      _refreshFilteredResults();
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Pretraži stipendije...",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      // focusedBorder: OutlineInputBorder(
                                      //   borderSide: BorderSide.none,
                                      //   borderRadius:
                                      //       BorderRadius.circular(8.0),
                                      // ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 16.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    setState(() {
                                      selectedSortOption = value;
                                    });
                                    _refreshFilteredResults();
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'Popularnost',
                                      child: Text('Popularnost'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Ocjena',
                                      child: Text('Ocjena'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Naziv A-Z',
                                      child: Text('Naziv A-Z'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Naziv Z-A',
                                      child: Text('Naziv Z-A'),
                                    ),
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
                                          selectedSortOption ?? 'Sortiraj po',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        if (selectedSortOption != null) ...[
                                          const SizedBox(width: 8.0),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedSortOption = null;
                                              });
                                              _refreshFilteredResults();
                                            },
                                            child: Icon(Icons.close, size: 20),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: _buildStipendijeList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: NumberPaginator(
                              numberPages:
                                  ((widget.totalItems / pageSize).ceil())
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(
      Stipendije stipendija, double averageRating, bool isRecommended) {
    return InkWell(
      onTap: () {
        widget.onCardTap(stipendija.id!, averageRating);
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
                    image: stipendija.idNavigation?.slika != null
                        ? DecorationImage(
                            image: NetworkImage(
                              FilePathManager.constructUrl(
                                  stipendija.idNavigation!.slika!),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  stipendija.idNavigation?.naslov ??
                                      'Bez naslova',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      averageRating == 0.0
                                          ? 'N/A'
                                          : averageRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < averageRating.round()
                                    ? Colors.black
                                    : Colors.grey,
                              );
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            stipendija.stipenditor?.naziv ?? 'Nepoznat',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                            ),
                            child: stipendija.nivoObrazovanja != null &&
                                    stipendija.nivoObrazovanja!.isNotEmpty
                                ? Text(
                                    stipendija.nivoObrazovanja!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(32.0),
                                  ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Builder(
                              builder: (context) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsScreen(
                                        postId: stipendija.id!,
                                        postType: ItemType.internship,
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
                              itemId: stipendija.id!,
                              itemType: ItemType.internship,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }
}
