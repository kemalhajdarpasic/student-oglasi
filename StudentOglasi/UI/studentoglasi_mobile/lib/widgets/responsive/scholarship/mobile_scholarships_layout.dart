import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

class MobileScholarshipsLayout extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final List<Stipendije> stipendije;
  final Map<int, double> averageRatings;
  final Function(int id, double avgRating) onCardTap;
  final void Function(dynamic filter) onFilterApplied;

  const MobileScholarshipsLayout({
    Key? key,
    required this.isLoading,
    required this.hasError,
    required this.stipendije,
    required this.averageRatings,
    required this.onCardTap,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<MobileScholarshipsLayout> createState() =>
      _MobileScholarshipsLayoutState();
}

class _MobileScholarshipsLayoutState extends State<MobileScholarshipsLayout> {
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
      if (selectedRating != null) 'MinimalnaOcjena': selectedRating,
      if (searchQuery != null && searchQuery!.isNotEmpty) 'naslov': searchQuery,
      if (selectedSortOption != null) 'sort': selectedSortOption,
      'page': currentPage,
      'pageSize': pageSize
    };
  }

  Future<void> _refreshFilteredResults() async {
    var filter = generateFilter();
    widget.onFilterApplied(filter); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showFilterOptions, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filtriraj",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Icon(Icons.filter_alt_outlined,
                          color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showSortOptions, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sortiraj",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Icon(Icons.sort, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.hasError
                  ? const Center(
                      child: Text(
                          'Neuspješno učitavanje podataka. Molimo pokušajte opet.'))
                  : widget.stipendije.isEmpty
                      ? Center(child: Text('Nema dostupnih podataka.'))
                      : ListView.builder(
                          itemCount: widget.stipendije.length,
                          itemBuilder: (context, index) {
                            final stipendija = widget.stipendije[index];
                            final averageRating =
                                widget.averageRatings[stipendija.id] ?? 0.0;
                            return _buildPostCard(
                                stipendija,
                                stipendija.isRecommended ?? false,
                                averageRating);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildPostCard(
      Stipendije stipendija, bool isRecommended, double averageRating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: InkWell(
          onTap: () {
            widget.onCardTap(stipendija.id!, averageRating);
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
                    Builder(builder: (context) {
                      return InkWell(
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
                      );
                    }),
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

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionTile(
                      title: Text(
                        selectedGradId != null
                            ? gradovi
                                    .firstWhere((g) => g.id == selectedGradId)
                                    .naziv ??
                                "Odaberi grad"
                            : "Odaberi grad",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: gradovi.map((grad) {
                        return ListTile(
                          title: Text(grad.naziv ?? ""),
                          onTap: () {
                            setModalState(() => selectedGradId = grad.id);
                            Navigator.pop(context);
                            _showFilterOptions();
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    ExpansionTile(
                      title: Text(
                        selectedStipenditorId != null
                            ? stipenditori
                                    .firstWhere(
                                        (s) => s.id == selectedStipenditorId)
                                    .naziv ??
                                "Odaberi stipenditora"
                            : "Odaberi stipenditora",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: stipenditori.map((stip) {
                        return ListTile(
                          title: Text(stip.naziv ?? ""),
                          onTap: () {
                            setModalState(
                                () => selectedStipenditorId = stip.id);
                            Navigator.pop(context);
                            _showFilterOptions();
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    ExpansionTile(
                      title: Text(
                        "Minimalna ocjena",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: RatingBar.builder(
                            initialRating: selectedRating ?? 0,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setModalState(() => selectedRating = rating);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _refreshFilteredResults();
                        },
                        child: Text("Primijeni filtere"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                  _buildSortButton("Ocjena"),
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
    bool isSelected = selectedSortOption == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedSortOption = title;
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
}
