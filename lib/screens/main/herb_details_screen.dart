import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HerbDetailsScreen extends StatefulWidget {
  final String herbID;

  const HerbDetailsScreen({Key? key, required this.herbID}) : super(key: key);

  @override
  State<HerbDetailsScreen> createState() => _HerbDetailsScreenState();
}

class _HerbDetailsScreenState extends State<HerbDetailsScreen> {
  static const Color _green = Color(0xFF2E774F);
  static const Color _greenDark = Color(0xFF256B46);
  static const Color _lightGreen = Color(0xFFE7F2EC);

  Map<String, dynamic>? herbData;
  bool _isFavorite = false;
  String? _favoriteID;
  bool _isLoading = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _loadHerb();
  }

  Future<void> _loadHerb() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // جلب بيانات العشبة
      final doc = await FirebaseFirestore.instance
          .collection('herbs')
          .doc(widget.herbID)
          .get();

      if (doc.exists) {
        herbData = doc.data();
      }

      // جلب حالة المفضلة من الفرع الجديد داخل المستخدم
      final favSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('favorites')
          .where('herbID', isEqualTo: widget.herbID)
          .limit(1)
          .get();

      if (favSnapshot.docs.isNotEmpty) {
        _isFavorite = true;
        _favoriteID = favSnapshot.docs.first.id;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error loading herb: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (herbData == null || _isToggling) return;

    setState(() => _isToggling = true);

    final userID = FirebaseAuth.instance.currentUser!.uid;
    final favCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('favorites');

    try {
      if (_isFavorite) {
        if (_favoriteID != null) {
          await favCollection.doc(_favoriteID).delete();
          setState(() {
            _isFavorite = false;
            _favoriteID = null;
          });
        }
      } else {
        final docRef = await favCollection.add({
          'herbID': widget.herbID,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isFavorite = true;
          _favoriteID = docRef.id;
        });
      }
    } on FirebaseException catch (e) {
      print("Error toggling favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "حدث خطأ أثناء تحديث المفضلة",
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final titleSize = (base * 0.05).clamp(18.0, 22.0);
    final textSize = (base * 0.04).clamp(14.0, 16.0);
    final padding = (base * 0.04).clamp(12.0, 16.0);
    final imageRadius = (base * 0.04).clamp(14.0, 20.0);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    if (herbData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "معلومات العشبة",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _greenDark,
              fontSize: titleSize,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: const Center(
          child: Text(
            "تعذر تحميل بيانات العشبة",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    final medicalUses = herbData!['medicalUses'] != null
        ? List<String>.from(herbData!['medicalUses'])
        : <String>[];
    final culinaryUses = herbData!['culinaryUses'] != null
        ? List<String>.from(herbData!['culinaryUses'])
        : <String>[];
    final imageUrl = herbData!['imageUrl'] ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "معلومات العشبة",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _greenDark,
              fontSize: titleSize,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black54),
          actions: [
            IconButton(
              icon: _isToggling
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: _green, strokeWidth: 2),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red.shade700 : _green,
                    ),
              onPressed: _isToggling ? null : _toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: CircularProgressIndicator(color: _green),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: _lightGreen,
                      child: const Center(
                        child: Icon(Icons.nature_people_outlined,
                            size: 50, color: _green),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: padding),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: padding / 2),
                child: Text(
                  herbData!['name'] ?? 'عشبة غير معروفة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _greenDark,
                    fontSize: titleSize * 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (medicalUses.isNotEmpty)
                _InfoCard(
                  title: 'الاستخدامات في العلاج:',
                  cardRadius: imageRadius,
                  children: medicalUses
                      .map((e) => _BulletPoint(text: e, textSize: textSize))
                      .toList(),
                ),
              if (culinaryUses.isNotEmpty)
                _InfoCard(
                  title: 'الاستخدامات في الطهي:',
                  cardRadius: imageRadius,
                  children: culinaryUses
                      .map((e) => _BulletPoint(text: e, textSize: textSize))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final double cardRadius;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.cardRadius,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF2E774F);
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final sectionTitleSize = (base * 0.045).clamp(16.0, 19.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.w800,
              fontSize: sectionTitleSize,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final double textSize;
  const _BulletPoint({required this.text, required this.textSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle,
                size: textSize * 0.6,
                color: const Color(0xFF2E774F).withOpacity(0.7)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.black87, fontSize: textSize, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
