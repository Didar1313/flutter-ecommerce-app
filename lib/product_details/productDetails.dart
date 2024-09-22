import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> products; // Make this a typed variable

  ProductDetails(this.products);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  var _dotPosition = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  void checkIfFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .collection('favorites')
          .doc(widget.products['id']);

      final doc = await favoriteRef.get();
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  void toggleFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to add items to favorites')),
      );
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('favorites')
        .doc(widget.products['id']);

    if (isFavorite) {
      await favoriteRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from favorites')),
      );
    } else {
      await favoriteRef.set({
        'productName': widget.products['product-name'],
        'price': widget.products['price'],
        'image': widget.products['product_image'][0],
        'addedAt': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to favorites')),
      );
    }

    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite status
    });
  }

  void _addItemToCart() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to add items to the cart')),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('cart');

    final existingItem = await cartRef
        .where('productName', isEqualTo: widget.products['product-name'])
        .limit(1)
        .get();

    if (existingItem.docs.isNotEmpty) {
      final cartItemRef = cartRef.doc(existingItem.docs.first.id);
      await cartItemRef.update({
        'quantity': FieldValue.increment(1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity increased for ${widget.products['product-name']}')),
      );
    } else {
      await cartRef.add({
        'productName': widget.products['product-name'],
        'price': widget.products['price'],
        'image': widget.products['product_image'][0],
        'quantity': 1,
        'addedAt': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.green[700],
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.green[700],
              child: IconButton(
                onPressed: toggleFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
                color: isFavorite ? Colors.greenAccent : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: CarouselSlider(
                items: widget.products['product_image']
                    .map<Widget>((item) => Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(item),
                          fit: BoxFit.fitWidth)),
                ))
                    .toList(),
                options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.5,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (val, carouselPagedChangedReason) {
                      setState(() {
                        _dotPosition = val;
                      });
                    }),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: DotsIndicator(
                dotsCount: widget.products['product_image'].length == 0
                    ? 1
                    : widget.products['product_image'].length,
                position: _dotPosition.toInt(),
                decorator: DotsDecorator(
                    activeColor: Colors.orange,
                    spacing: EdgeInsets.all(2),
                    activeSize: Size(8, 8),
                    size: Size(6, 6),
                    color: Colors.orange.withOpacity(0.5)),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.products['product-name'],
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          widget.products['price'],
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          widget.products["product_description"]?.toString() ??
                              'No description available',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: 250.h,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(80, 0, 0, 0),
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green[700],
                          ),
                          child: RawMaterialButton(
                            elevation: 0,
                            onPressed: _addItemToCart, // Call the new function
                            child: Text(
                              "Add To Cart",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
