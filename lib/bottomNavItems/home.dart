import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:ecommerceapp/product_details/productDetails.dart';
import 'package:ecommerceapp/search/searchItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _dotPosition = 0;
  TextEditingController _searchController = TextEditingController();
  var _firebaseAuth = FirebaseFirestore.instance;
  List<String> _carouselImageList = [];
  List<Map<String, dynamic>> _product = [];

  _fetchCarouselImage() async {
    QuerySnapshot qn = await _firebaseAuth.collection("Cursor-product").get();
    setState(() {
      for (var doc in qn.docs) {
        List<dynamic> productImages = doc["product-images"];
        _carouselImageList.addAll(productImages.cast<String>());
      }
    });
  }

  _fetchProduct() async {
    QuerySnapshot qn = await FirebaseFirestore.instance.collection("products").get();
    setState(() {
      for (var doc in qn.docs) {
        _product.add({
          "product-name": doc["product-name"],
          "product-description": doc["product_description"],
          "price": doc["price"],
          "product_image": doc["product_image"],
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCarouselImage();
    _fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(  // Allow scrolling if needed
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: 15.h),
                _buildCarousel(),
                SizedBox(height: 10.h),
                _buildProductGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchingItem()));
            },
            decoration: InputDecoration(
              hintText: "Search your items...",
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3,
          child: CarouselSlider(
            items: _carouselImageList.map((item) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(item), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(15),
              ),
            )).toList(),
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.4,
              onPageChanged: (val, carouselPagedChangedReason) {
                setState(() {
                  _dotPosition = val;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 10.h),
        DotsIndicator(
          dotsCount: _carouselImageList.length == 0 ? 1 : _carouselImageList.length,
          position: _dotPosition.toInt(),
          decorator: DotsDecorator(
            activeColor: Colors.orange,
            spacing: EdgeInsets.all(2),
            activeSize: Size(8, 8),
            size: Size(6, 6),
            color: Colors.orange.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // Give a fixed height for the grid
      child: GridView.builder(
        scrollDirection: Axis.vertical, // Disable scrolling for the grid
        shrinkWrap: true, // Allow grid to wrap its content
        itemCount: _product.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Set to 3
          childAspectRatio: 0.7, // Adjust aspect ratio to fit items better
          mainAxisSpacing: 10, // Add spacing between rows
          crossAxisSpacing: 10, // Add spacing between columns
        ),
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetails(_product[index])),
            ),
            child: Card(
              elevation: 3,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1, // Adjust to fit the image correctly
                    child: Image.network(
                      _product[index]["product_image"][0],
                      fit: BoxFit.cover, // Ensure the image covers the area
                    ),
                  ),
                  SizedBox(height: 5), // Add some space
                  Text(
                    "${_product[index]["product-name"]}",
                    style: TextStyle(fontSize: 16), // Adjust font size
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                  SizedBox(height: 5), // Add some space
                  Text(
                    "${_product[index]["price"]}",
                    style: TextStyle(fontSize: 14, color: Colors.grey), // Style for price
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
