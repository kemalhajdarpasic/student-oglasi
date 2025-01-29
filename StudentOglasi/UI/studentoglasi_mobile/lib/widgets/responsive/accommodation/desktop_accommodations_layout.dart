import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Grad/grad.dart';
import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/models/TipSmjestaja/tip_smjestaja.dart';
import 'package:studentoglasi_mobile/providers/gradovi_provider.dart';
import 'package:studentoglasi_mobile/providers/tip_smjestaja_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';
import 'package:number_paginator/number_paginator.dart';

class DesktopAccommodationsLayout extends StatefulWidget {
  final List<Smjestaj> smjestaji;
  final Map<int, double> averageRatings;
  final Function(int, double) onCardTap;
  final void Function(dynamic filter) onFilterApplied;
  final int totalItems;

  const DesktopAccommodationsLayout({
    Key? key,
    required this.smjestaji,
    required this.averageRatings,
    required this.onCardTap,
    required this.onFilterApplied,
    required this.totalItems,
  }) : super(key: key);

  @override
  _DesktopAccommodationsLayoutState createState() =>
      _DesktopAccommodationsLayoutState();
}

class _DesktopAccommodationsLayoutState
    extends State<DesktopAccommodationsLayout> {
  List<Grad> gradovi = [];
  List<TipSmjestaja> tipoviSmjestaja = [];
  double? selectedRating;
  int? selectedGradId;
  int? selectedTipSmjestajaId;
  List<String> selectedServices = [];
  List<int> selectedRatings = [];
  List<String> dostupneUsluge = [
    'WiFi',
    'Parking',
    'Fitness Centar',
    'Restoran',
    'Usluge prijevoza',
  ];
  String? searchQuery;
  String? selectedSortOption;

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
    final tipSmjestajaProvider =
        Provider.of<TipSmjestajaProvider>(context, listen: false);

    final gradoviResult = await gradoviProvider.get();
    final tipoviResult = await tipSmjestajaProvider.get();

    setState(() {
      gradovi = gradoviResult.result;
      tipoviSmjestaja = tipoviResult.result;
    });
  }

  Map<String, dynamic> generateFilter() {
    return {
      if (selectedGradId != null) 'GradID': selectedGradId,
      if (selectedTipSmjestajaId != null)
        'TipSmjestajaID': selectedTipSmjestajaId,
      if (selectedRatings.isNotEmpty) 'ProsjecneOcjene': selectedRatings,
      if (selectedServices.isNotEmpty) 'DodatneUsluge': selectedServices,
      if (searchQuery != null && searchQuery!.isNotEmpty) 'naziv': searchQuery,
      if (selectedSortOption != null) 'sort': selectedSortOption,
      'page': currentPage,
      'pageSize': pageSize
    };
  }

  bool hasActiveFilters() {
    return selectedGradId != null ||
        selectedTipSmjestajaId != null ||
        selectedRatings.isNotEmpty ||
        selectedServices.isNotEmpty ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        selectedSortOption != null;
  }

  Future<void> _refreshFilteredResults() async {
    var filter = generateFilter();
    // final smjestajiProvider =
    //     Provider.of<SmjestajiProvider>(context, listen: false);

    // final filteredResults = await smjestajiProvider.get(filter: filter);

    // setState(() {
    //   widget.smjestaji.clear();
    //   widget.smjestaji.addAll(filteredResults.result);
    // });
    widget.onFilterApplied(filter);
  }

  List<Widget> _buildSmjestajiList() {
    if (widget.smjestaji.isEmpty) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Text(
              'Nema dostupnih smještaja.',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    final recommendedSmjestaji =
        widget.smjestaji.where((s) => s.isRecommended == true).toList();
    final otherSmjestaji =
        widget.smjestaji.where((s) => s.isRecommended != true).toList();

    bool shouldShowSingleList =
        selectedSortOption != null || recommendedSmjestaji.isEmpty;

    if (shouldShowSingleList) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Smještaji',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      widgets.addAll(widget.smjestaji.map((smjestaj) {
        final averageRating = widget.averageRatings[smjestaj.id] ?? 0.0;
        return _buildPostCard(
            smjestaj, averageRating, smjestaj.isRecommended ?? false);
      }).toList());
    } else {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Preporučeni smještaji',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      widgets.addAll(recommendedSmjestaji.map((smjestaj) {
        final averageRating = widget.averageRatings[smjestaj.id] ?? 0.0;
        return _buildPostCard(smjestaj, averageRating, true);
      }).toList());

      if (otherSmjestaji.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ostali smještaji',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );

        widgets.addAll(otherSmjestaji.map((smjestaj) {
          final averageRating = widget.averageRatings[smjestaj.id] ?? 0.0;
          return _buildPostCard(smjestaj, averageRating, false);
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
                                        selectedTipSmjestajaId = null;
                                        selectedServices.clear();
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
                                    SizedBox(height: 8),
                                    ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tip smještaja',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedTipSmjestajaId != null)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedTipSmjestajaId = null;
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
                                      children: tipoviSmjestaja.map((tip) {
                                        return ListTile(
                                          title: Text(tip.naziv ?? ''),
                                          leading: Radio<int>(
                                            value: tip.id!,
                                            groupValue: selectedTipSmjestajaId,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedTipSmjestajaId = value;
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
                                            'Dostupne usluge',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedServices.isNotEmpty)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedServices.clear();
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
                                          children:
                                              dostupneUsluge.map((usluga) {
                                            return Row(
                                              children: [
                                                Checkbox(
                                                  value: selectedServices
                                                      .contains(usluga),
                                                  onChanged: (isChecked) {
                                                    setState(() {
                                                      if (isChecked == true) {
                                                        selectedServices
                                                            .add(usluga);
                                                      } else {
                                                        selectedServices
                                                            .remove(usluga);
                                                      }
                                                      _refreshFilteredResults();
                                                    });
                                                  },
                                                ),
                                                Text(usluga),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
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
                                      hintText: "Pretraži smještaje...",
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
                              children: _buildSmjestajiList(),
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
      Smjestaj smjestaj, double averageRating, bool isRecommended) {
    return InkWell(
      onTap: () {
        widget.onCardTap(smjestaj.id!, averageRating);
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
                    image:
                        smjestaj.slikes != null && smjestaj.slikes!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  FilePathManager.constructUrl(
                                      smjestaj.slikes!.first.naziv!),
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
                              Text(
                                smjestaj.naziv ?? 'Bez naslova',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                            smjestaj.grad?.naziv ?? 'Nepoznati grad',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              if (smjestaj.wiFi == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('WiFi'),
                                ),
                              if (smjestaj.parking == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Parking'),
                                ),
                              if (smjestaj.fitnessCentar == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Fitness Centar'),
                                ),
                              if (smjestaj.restoran == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Restoran'),
                                ),
                              if (smjestaj.uslugePrijevoza == true)
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  child: Text('Usluge prijevoza'),
                                ),
                            ],
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
                                        postId: smjestaj.id!,
                                        postType: ItemType.accommodation,
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
                              itemId: smjestaj.id!,
                              itemType: ItemType.accommodation,
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
