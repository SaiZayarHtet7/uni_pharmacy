
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_pharmacy/models/CategoryModel.dart';
import 'package:uni_pharmacy/models/GetandSet.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class EditCategory extends StatefulWidget {
  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  ScrollController _controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        title: Text('Category'),
      backgroundColor: Constants.primaryColor,),
      body: Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
            stream:FirestoreService().get('category'),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(snapshot.hasError){
                return Text('Something went wrong');
              } if(snapshot.connectionState== ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return  new ListView(
                shrinkWrap: true,
                controller: _controller,
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  return InkWell(
                    onTap: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> CRUD_Category(document.data()['category_image'],document.data()['category_name'],document.data()['id'])));

                    },
                    child: new  Container(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 33.0,
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              document.data()['category_name'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: Constants.PrimaryFont,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Container(
                            child: CachedNetworkImage(
                              imageUrl: document.data()['category_image'],
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => Container(
                                height: 120.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border:Border.all(color: Colors.black,width: 1),
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Container(height: 100, child: Center(child: CircularProgressIndicator())),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          SizedBox(height: 10.0,)
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>CRUD_Category("","","")));
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Constants.primaryColor,
      ),
    );
  }

  Widget CategoryCard(String name,String url,String id){
    return InkWell(
      onTap:(){
        Navigator.push(context,MaterialPageRoute(builder: (context)=>CRUD_Category(url,name,id)));
      },
      child: Container(
        padding: EdgeInsets.all(0),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border:Border.all(width: 1.0, color: Colors.black),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(0),
              height: 120,
              width: double.infinity,
                    decoration:BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft:Radius.circular(28),topRight: Radius.circular(28)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          '$url'
                        )
                      )
                    ) ,
            ),
            Container(
                  child: Text('$name',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 15,),),
            ),
          ],
        ),
      ),
    );
  }
}

class CRUD_Category extends StatefulWidget {
  final String imageUrl,categoryName,uuid;
  CRUD_Category(this.imageUrl,this.categoryName,this.uuid);
  @override
  _CRUD_CategoryState createState() => _CRUD_CategoryState(imageUrl,categoryName,uuid);
}

class _CRUD_CategoryState extends State<CRUD_Category> {
  final _formKey = GlobalKey<FormState>();
  var uuidLib=Uuid();
   String imageUrl="",categoryName="",uuid="";
  final picker = ImagePicker();
  File slideImage;
  bool loading;
  final categoryController=TextEditingController();
  _CRUD_CategoryState(this.imageUrl, this.categoryName,this.uuid);
  @override
  void initState() {
    // TODO: implement initState
    categoryController.text=categoryName;
    loading=false;
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        title: Text('Edit Category'),backgroundColor: Constants.primaryColor,),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: categoryController,
                  style: TextStyle(
                      fontSize: 17.0,
                      fontFamily: Constants.PrimaryFont
                  ),
                  decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                      hintText: 'Eg.သောက်ဆေး',
                      enabledBorder: new OutlineInputBorder(
                        borderSide:new BorderSide(color: Constants.primaryColor),
                      ),
                      focusedBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Constants.primaryColor)
                      ),
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Constants.primaryColor),
                      )
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter Category Name';
                    }
                    return null;
                  },
                ),
                Container(height: 10,),
                Text(
                  'ဓါတ်ပုံရွှေးရန်',style: TextStyle(
                  color: Constants.primaryColor,
                  fontSize: 15,
                ),
                ),
                Container(

                  child:loading==false? Container(
                    child:
                    InkWell(
                      onTap: (){
                        _onButtonPressed_for_image(context);
                      },
                      child:imageUrl!="" ? CachedNetworkImage(
                        imageUrl: imageUrl, fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(
                              child: Container(
                                  child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)),
                            ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ):Center(
                        child: IconButton(
                          onPressed:(){
                            _onButtonPressed_for_image(context);
                          },
                          icon:Icon( Icons.camera_alt,color: Constants.primaryColor,),
                          iconSize: 50,
                        ),
                      ),
                    )
                  ):
                  Center(
                    child: Container(
                        child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal:20.0),
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        if(imageUrl!=""){
                          if (uuid == "") {
                            ///insert data
                            CategoryModel categorymodel = CategoryModel(
                                id: uuidLib.v4().toString(),
                                categoryName: categoryController.text,
                                categoryImage: imageUrl
                            );
                            FirestoreService().saveCategory('category',
                                categorymodel);
                          } else {
                            ///editing data
                            CategoryModel categorymodel = CategoryModel(
                                id: uuid,
                                categoryName: categoryController.text,
                                categoryImage: imageUrl
                            );
                            FirestoreService().editCategory('category',
                                categorymodel);
                          }
                          Navigator.pop(context);
                        }
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('ကျေးဇူးပြု၍ ဓါတ်ပုံရွှေးပါ'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Constants.emergencyColor,
                        ));
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Hexcolor('#fd9346'),Constants.primaryColor,Hexcolor('#fd9346'),],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(uuid=="" ? 'သိမ်းဆည်းမည်':"ပြင်ဆင်မည်",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onButtonPressed_for_image(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text( 'ပုံအသစ်ယူပါ'),
                      onTap: () {
                        _openCamera(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('ပုံအသစ်ရွေးပါ'),
                      onTap: () {
                        _openGallary(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel),
                      title: Text('ပယ်ဖျက်ပါ'),
                      onTap: () => Navigator.pop(context),
                    )
                  ],
                ),

              ],
            ),
          );
        });
  }

  Future _openGallary(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    File tmpFile = File(picture.path);
    slideImage= tmpFile;
    Navigator.pop(context);
    setState((){
      loading=true;
    });
    if(imageUrl=="") {
      imageUrl =
      await FirebaseStorageService().UploadPhoto('category', slideImage);
    }else{
      var newImage=await FirebaseStorageService().EditPhoto(imageUrl, 'category', slideImage);
      imageUrl=newImage.toString();
    }
    print(imageUrl);
    setState(() {
      loading=false;
    });
  }

  Future _openCamera(BuildContext context) async {
    final picture = await picker.getImage(source: ImageSource.camera);
    File tmpFile = File(picture.path);

    slideImage= tmpFile;Navigator.pop(context);
    setState(() {
      loading=true;
    });
    if(imageUrl=="") {
      imageUrl = await FirebaseStorageService().UploadPhoto('category', slideImage);
    }else{
     var newImage=await FirebaseStorageService().EditPhoto(imageUrl, 'category', slideImage);
     imageUrl=newImage.toString();
    }
    setState(() {
      loading=false;
    });

  }

}
