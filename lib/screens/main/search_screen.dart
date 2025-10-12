import 'dart:async';
import 'package:aushbh/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'herb_details_screen.dart';

// الألوان الموحدة
const Color _green = Color(0xFF2E774F);
const Color _greenDark = Color(0xFF256B46);
const Color _lightGreen = Color(0xFFE7F2EC);

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-herbs';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // دالة البحث مع Debounce
  void _searchHerbs(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        setState(() {
          _results = [];
          _errorMessage = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('herbs')
            .where('name', isGreaterThanOrEqualTo: trimmedQuery)
            .where('name', isLessThanOrEqualTo: trimmedQuery + '\uf8ff')
            .get();

        final herbs = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'imageUrl': doc['imageUrl'] ?? '',
          };
        }).toList();

        setState(() {
          _results = herbs;
          _isLoading = false;
        });
      } catch (e) {
        print('Error searching herbs: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = "حدث خطأ أثناء البحث: ${e.toString()}";
        });
      }
    });
  }

  void _openHerbDetails(String herbID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HerbDetailsScreen(herbID: herbID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "البحث عن الأعشاب",
            style: TextStyle(
                color: _greenDark, fontWeight: FontWeight.w800, fontSize: 22),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
            _buildResultsHeader(),
            Expanded(child: _buildResultsBody()),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchHerbs,
        decoration: InputDecoration(
          hintText: "ابحث عن عشبة",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: _greenDark, size: 24),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                    _searchHerbs('');
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    if (_searchController.text.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          "ابدأ بكتابة اسم العشبة لعرض النتائج هنا",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          _errorMessage!,
          style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        _isLoading ? "جارِ البحث..." : "تم العثور على ${_results.length} نتائج:",
        style: const TextStyle(fontSize: 16, color: _greenDark, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_results.isEmpty) {
      if (_errorMessage != null) {
        return const SizedBox.shrink();
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "لا توجد نتائج مطابقة لـ '${_searchController.text}'",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _results.length,
      itemBuilder: (_, index) {
        final herb = _results[index];
        return _HerbSearchResultCard(
          herb: herb,
          onTap: () => _openHerbDetails(herb['id']),
        );
      },
    );
  }
}

// كارد العمودي الجديد
class _HerbSearchResultCard extends StatelessWidget {
  final Map<String, dynamic> herb;
  final VoidCallback onTap;

  const _HerbSearchResultCard({required this.herb, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: herb['imageUrl'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: double.infinity,
                  height: 120,
                  color: _lightGreen.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator(color: _green)),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error, size: 30, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              herb['name'],
              style: const TextStyle(
                color: _greenDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text("انقر للمزيد", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
