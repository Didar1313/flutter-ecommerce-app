import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchingItem extends StatefulWidget {
  const SearchingItem({super.key});

  @override
  State<SearchingItem> createState() => _SearchingItemState();
}

class _SearchingItemState extends State<SearchingItem> {
  var inputText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                onChanged: (val) {
                  setState(() {
                    inputText = val;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Search your items....",
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.red)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Color(0xFF09adfe)))),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("products")
                      .where("product-name", isEqualTo: inputText)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error Occured",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: AppColors.deep_green),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text(
                          "Something wrong in ConnectionState",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: AppColors.deep_green),
                        ),
                      );
                    }
                    return ListView(
                      children: snapshot.data!.docs.map((document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(data['product-name']),
                            leading: Image.network(data['product_image'][0]),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
