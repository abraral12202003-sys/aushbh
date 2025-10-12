import 'package:aushbh/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'herb_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const String routeName = '/favorites';
  final String userID = FirebaseAuth.instance.currentUser!.uid;

  static const Color _green = Color(0xFF2E774F);
  static const Color _greenDark = Color(0xFF256B46);

  FavoritesScreen({Key? key}) : super(key: key);

  /// حذف عنصر من المفضلة (فرع المستخدم) مع التعامل مع الأخطاء
  void _removeFavorite(BuildContext context, String favoriteID) async {
    final favDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('favorites')
        .doc(favoriteID);

    try {
      final docSnapshot = await favDocRef.get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "تم حذف العشبة مسبقًا من المفضلة",
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await favDocRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تمت إزالة العشبة من المفضلة",
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء الإزالة: ${e.toString()}",
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// فتح شاشة تفاصيل العشبة
  void _openHerbDetails(BuildContext context, String herbID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HerbDetailsScreen(herbID: herbID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final titleSize = (base * 0.045).clamp(16.0, 20.0);
    final itemTitleSize = (base * 0.042).clamp(15.0, 18.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "المفضلة",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _greenDark,
                fontSize: titleSize),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Builder(
          builder: (scaffoldContext) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 70, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "لا توجد أعشاب في المفضلة بعد",
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "أضف الأعشاب التي تهمك للوصول السريع إليها.",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final favDocs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: favDocs.length,
                  itemBuilder: (context, index) {
                    final favDoc = favDocs[index];
                    final favoriteID = favDoc.id;
                    final herbID = favDoc['herbID'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('herbs')
                          .doc(herbID)
                          .get(),
                      builder: (context, herbSnapshot) {
                        if (!herbSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!herbSnapshot.data!.exists) {
                          // إذا تم حذف العشبة من الفرع الأساسي
                          return const SizedBox();
                        }
                        final herbDoc = herbSnapshot.data!;
                        final herbName = herbDoc['name'] ?? 'عشبة غير معروفة';
                        final herbImage = herbDoc['imageUrl'] ?? '';

                        return _FavoriteHerbCard(
                          herb: {
                            'herbID': herbID,
                            'name': herbName,
                            'imageUrl': herbImage,
                            'favoriteID': favoriteID,
                          },
                          itemTitleSize: itemTitleSize,
                          onTap: () => _openHerbDetails(context, herbID),
                          onRemove: () =>
                              _removeFavorite(scaffoldContext, favoriteID),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      ),
    );
  }
}

class _FavoriteHerbCard extends StatelessWidget {
  final Map<String, dynamic> herb;
  final double itemTitleSize;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteHerbCard({
    required this.herb,
    required this.itemTitleSize,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const Color _green = Color(0xFF2E774F);
    const Color _greenDark = Color(0xFF256B46);

    final w = MediaQuery.of(context).size.width;
    final cardRadius = (w * 0.04).clamp(14.0, 20.0);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: _green.withOpacity(0.2), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: _green.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(cardRadius)),
                  child: CachedNetworkImage(
                    imageUrl: herb['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFF2F6F4),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: _green.withOpacity(0.7))),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 4)
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                      onPressed: onRemove,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  herb['name'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: itemTitleSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: (w * 0.06).clamp(26.0, 30.0),
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _greenDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      elevation: 1,
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      "انقر للمزيد",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
