import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy/models/ProductModel.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/EditProduct.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String url, name, description;
  List<ProductModel> product = [];
  String searchName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Category'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(0),
              child: TextFormField(
                keyboardType: TextInputType.name,
                style: TextStyle(
                    fontSize: 17.0, fontFamily: Constants.PrimaryFont),
                onChanged: (value) {
                  setState(() {
                    searchName = value.toString();
                  });
                },
                decoration: InputDecoration(
                    hintText: 'အမည်ဖြင့်ရှာမည်',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Constants.primaryColor,
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Constants.primaryColor),
                    ),
                    focusedBorder: new OutlineInputBorder(
                        borderSide:
                            new BorderSide(color: Constants.primaryColor)),
                    border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Constants.primaryColor),
                    )),
              ),
            ),
            Container(
              margin:  EdgeInsets.only(top: 90),
              child:StreamBuilder<QuerySnapshot>(
                  stream: (searchName=="" || searchName==null) ? FirestoreService().get('product'):FirebaseFirestore.instance
                      .collection('product').where("product_search", arrayContains : searchName).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    return new GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5),
                      children: snapshot.data.docs
                          .map(
                            (DocumentSnapshot document) => ProductCard(
                                document.data()['product_id'],
                                document.data()['product_name'],
                                document.data()['description'],
                                document.data()['product_image'],
                                document.data()['category']),
                          )
                          .toList(),
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EditProduct("", "", "", "", "")));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Constants.primaryColor,
      ),
    );
  }

  Widget ProductCard(String id, String name, String description, String photo,
      String category) {
    return InkWell(
      onTap: () {
        print("Product id is == "+id);
        print('PRoduct name is == '+ name);
        print('PRoduct description =='+description);
        print("product photo =="+photo);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditProduct(name, photo, id, description, category)));
      },
      child: Container(
        padding: EdgeInsets.all(0),
        height: 105,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black,)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                height: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9)),
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 5.0,),
            Container(
              height: 25.0,
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '$name',
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontFamily: Constants.PrimaryFont,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
