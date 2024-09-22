import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:ecommerceapp/product_details/productDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Favor extends StatefulWidget {
  const Favor({super.key});

  @override
  State<Favor> createState() => _FavorState();
}

class _FavorState extends State<Favor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Favorites',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser != null
            ? FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('favorites')
            .get()
            : null,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching favorites'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100.sp, color: Colors.grey),
                  SizedBox(height: 20.h),
                  Text(
                    'No favorite items',
                    style: TextStyle(fontSize: 20.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // List of favorited products
          var favoriteProducts = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.w),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              var product = favoriteProducts[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.w),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product['image'],
                        width: 60.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product['productName'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Price: \$${product['price']}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeFromFavorites(product.id);
                      },
                    ),
                    onTap: () {
                      // Navigate to product details

                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Remove an item from favorites
  void removeFromFavorites(String productId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .collection('favorites')
          .doc(productId);

      await favoriteRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from favorites')),
      );

      // Update the UI
      setState(() {});
    }
  }
}
