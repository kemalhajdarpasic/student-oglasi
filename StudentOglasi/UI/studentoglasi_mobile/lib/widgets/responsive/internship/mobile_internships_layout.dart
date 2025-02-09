import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/models/Grad/grad.dart';
import 'package:studentoglasi_mobile/models/Organizacije/organizacije.dart';
import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import 'package:studentoglasi_mobile/providers/gradovi_provider.dart';
import 'package:studentoglasi_mobile/providers/organizacije_provider.dart';
import 'package:studentoglasi_mobile/screens/components/comments_screen.dart';
import 'package:studentoglasi_mobile/utils/item_type.dart';
import 'package:studentoglasi_mobile/utils/util.dart';
import 'package:studentoglasi_mobile/widgets/like_button.dart';

class MobileInternshipsLayout extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final List<Praksa> prakse;
  final Map<int, double> averageRatings;
  final Function(int id, double avgRating) onCardTap;
  final void Function(dynamic filter) onFilterApplied;

  const MobileInternshipsLayout({
    Key? key,
    required this.isLoading,
    required this.hasError,
    required this.prakse,
    required this.averageRatings,
    required this.onCardTap,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<MobileInternshipsLayout> createState() =>
      _MobileInternshipsLayoutState();
}

class _MobileInternshipsLayoutState extends State<MobileInternshipsLayout> {
  List<Grad> gradovi = [];
  List<Organizacije> organizacije = [];
  List<int> selectedRatings = [];
  double? selectedRating;
  int? selectedGradId;
  String? searchQuery;
  String? selectedSortOption;
  int? selectedOrganizacijaId;

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
    final organizacijeProvider =
        Provider.of<OrganizacijeProvider>(context, listen: false);

    final gradoviResult = await gradoviProvider.get();
    final organizacijeResult = await organizacijeProvider.get();

    setState(() {
      gradovi = gradoviResult.result;
      organizacije = organizacijeResult.result;
    });
  }

  Map<String, dynamic> generateFilter() {
    return {
      if (selectedGradId != null) 'GradID': selectedGradId,
      if (selectedOrganizacijaId != null)
        'OrganizacijaID': selectedOrganizacijaId,
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
                  : widget.prakse.isEmpty
                      ? Center(child: Text('Trenutno nema dostupnih praksi.'))
                      : ListView.builder(
                          itemCount: widget.prakse.length,
                          itemBuilder: (context, index) {
                            final praksa = widget.prakse[index];
                            final averageRating =
                                widget.averageRatings[praksa.id] ?? 0.0;
                            return _buildPostCard(praksa,
                                praksa.isRecommended ?? false, averageRating);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildPostCard(
      Praksa praksa, bool isRecommended, double averageRating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: InkWell(
          onTap: () {
            widget.onCardTap(praksa.id!, averageRating);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    praksa.idNavigation?.slika != null
                        ? Image.network(
                            FilePathManager.constructUrl(
                                praksa.idNavigation!.slika!),
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
                  praksa.idNavigation?.naslov ?? 'Nema naziva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  praksa.idNavigation?.opis ?? 'Nema sadržaja',
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
                              postId: praksa.id!,
                              postType: ItemType.internship,
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
                      itemId: praksa.id!,
                      itemType: ItemType.internship,
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
                        selectedOrganizacijaId != null
                            ? organizacije
                                    .firstWhere(
                                        (s) => s.id == selectedOrganizacijaId)
                                    .naziv ??
                                "Odaberi organizaciju"
                            : "Odaberi organizaciju",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: organizacije.map((organizacija) {
                        return ListTile(
                          title: Text(organizacija.naziv ?? ""),
                          onTap: () {
                            setModalState(
                                () => selectedOrganizacijaId = organizacija.id);
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
