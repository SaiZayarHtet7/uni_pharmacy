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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
        title: Text('ဆေးပစ္စည်းများ'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(0),
              height: 50,
              child: TextFormField(
                keyboardType: TextInputType.name,
                style: TextStyle(
                    fontSize: 15.0, fontFamily: Constants.PrimaryFont),
                onChanged: (value) {
                  setState(() {
                    searchName = value.toString().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(2),
                    hintText: 'အမည်ဖြင့်ရှာမည်',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Constants.primaryColor,
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: new BorderSide(color: Colors.black,width: 1),
                    ),
                    focusedBorder: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: new BorderSide(color: Colors.black,width: 1),),
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: new BorderSide(color: Colors.black,width: 1),
                    )),
              ),
            ),
            Container(
              margin:  EdgeInsets.only(top: 60),
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
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10),
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
      child:  Container(
        padding: EdgeInsets.all(0),
        height:170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              height: 33,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      '$name',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: Constants.PrimaryFont,
                        fontSize: 17,
                      ),
                    ),],
                ),
              ),
            ),
            SizedBox(height: 5.0,),
            Container(
              child: CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  height: 115.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border:Border.all(color: Colors.black,width: 1),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Container(height: 100, child: Center(child: CircularProgressIndicator())),
                 errorWidget: (context, url, error) =>
                     Container(
                       height: 115.0,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(9),
                         border:Border.all(color: Colors.black,width: 1),
                         image: DecorationImage(
                           image: AssetImage(
                               'assets/image/logo.jpg'),
                           fit: BoxFit.cover,
                         ),
                         shape: BoxShape.rectangle,
                       ),
                     )
                     //ClipRRect(
                //     borderRadius: BorderRadius.circular(8.0),
                //     child: Image.asset('assets/image/logo.jpg',height: 120.0,fit: BoxFit.cover,)),
              ),
            ),
            SizedBox(height: 10.0,)
          ],
        ),
      )
    );
  }
}
