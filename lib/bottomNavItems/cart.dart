import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No user is logged in',
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
      );
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Cart',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100.sp, color: Colors.grey),
                  SizedBox(height: 20.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.w),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['image'],
                            height: 80.h,
                            width: 80.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10.w),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productName'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'Price: \$${item['price']}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'Quantity: ${item['quantity']}',
                                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Remove Button
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 28.sp),
                          onPressed: () {
                            _removeItemFromCart(item.id, item['quantity']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
 );
  }

  void _removeItemFromCart(String cartItemId, int currentQuantity) async {
    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .collection('cart')
        .doc(cartItemId);

    if (currentQuantity > 1) {
      await cartItemRef.update({
        'quantity': FieldValue.increment(-1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity decreased')),
      );
    } else {
      await cartItemRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from cart')),
      );
    }
  }
}
