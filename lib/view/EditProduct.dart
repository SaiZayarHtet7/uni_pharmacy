import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_pharmacy/models/PriceModel.dart';
import 'package:uni_pharmacy/models/ProductModel.dart';
import 'package:uni_pharmacy/models/UpdatPrice.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/ProductPage.dart';
import 'package:uni_pharmacy/view/Widget/PriceCard.dart';
import 'package:uni_pharmacy/view/Widget/ToastContext.dart';
import 'package:uni_pharmacy/view/Widget/ToastNoContext.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class EditProduct extends StatefulWidget {

  final String productName,productImage,productId,productDescription,category;

  const EditProduct(this.productName, this.productImage, this.productId, this.productDescription, this.category);
  @override
  _EditProductState createState() => _EditProductState(productId,productName,productDescription,productImage,category);
}

class _EditProductState extends State<EditProduct> {
  ///declaration
  String productName,productImage,productId,productDescription,category;
  var uuid=Uuid();
  final productNameController=TextEditingController();
  final productDescriptionController=TextEditingController();
  final priceController=TextEditingController();
  final quantityController=TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyBottom = GlobalKey<FormState>();
  File slideImage;
  final picker = ImagePicker();
  bool  loading;
  bool startLoading;
  String categorySelected,newCategory,unit,kindPrice;
  List<String> categoryList=new List();
  List<String> unitList=new List();
  List<String> kindList=["လက်လီစျေး","လက်ကားစျေး","အထူးစျေး"];
  _EditProductState(this.productId,this.productName,this.productDescription,this.productImage,this.category);

  @override
  void initState() {
    // TODO: implement initState
    loading=false;

    startLoading=true;
    fetchData();
    if(productId!=""){
      productNameController.text=productName;
      productDescriptionController.text=productDescription;
      setState(() {
        categorySelected=category.toString();
        print(categorySelected);
      });
    }
    super.initState();
  }

  ///fetching data
  fetchData() async{
    FirebaseFirestore.instance.collection("category").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          categoryList.add(result.data()['category_name'].toString());
          print(categoryList);
        });
      });
    });
    FirebaseFirestore.instance.collection("unit").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          unitList.add(result.data()['unit'].toString());
          print(unitList);
        });

        setState(() {
          startLoading=false;
        });
      });
    });
  }

  Future<bool> _onWillPop() {
    print(productId);
    if(productId==""){
      if(productImage!="" && productImage!= null) {
        FirebaseStorageService().DeletePhoto(productImage);
      }
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductPage()));
  }
  ///for search Algorithm
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  String validateName(String value) {
// Indian Mobile number are of 10 digit only
    if (value =="")
      return 'အမည် ထည့်ပါ';
    else
      return null;
  }

  String validateDescription(String value){
    if (value =="")
      return 'အကြောင်းအရာထည့်ပါ';
    else
      return null;
  }
  
  @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: MaterialApp(
        home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
              title: Text('Edit Product'),backgroundColor: Constants.primaryColor,
           leading: IconButton(
                icon:Icon( Icons.arrow_back_ios_rounded),
                onPressed: (){if(productId=="" || productId==null){
                  if(productImage!="" && productImage!= null) {
                    FirebaseStorageService().DeletePhoto(productImage);
                  }
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductPage()));})
            ),
          body: startLoading==true ? Center(child: CircularProgressIndicator(),): SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(width: MediaQuery.of(context).size.width, child: Text('ဓါတ်ပုံရွေးပါ',style: TextStyle(fontSize: 15.0,fontFamily: Constants.PrimaryFont),)),
                    SizedBox(height: 10.0,),
                   loading==true?Center(
                     child: Container(width: 120.0,
                         height: 120.0,
                         child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)),
                   ) :InkWell(
                      onTap: (){
                        _onButtonPressed_for_image(context);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1,color: Constants.thirdColor
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: productImage=="" ? Icon(Icons.widgets,color: Constants.secondaryColor,size: 50,):
                        CachedNetworkImage(
                          imageUrl: productImage,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      )
                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                      controller: productNameController,
                      validator: validateName,
                      style: TextStyle(
                          fontSize: 17.0,
                          fontFamily: Constants.PrimaryFont
                      ),
                      decoration: InputDecoration(
                          labelText: 'အမည်',
                          labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                          hintText: '',
                          enabledBorder: new OutlineInputBorder(
                            borderSide:new BorderSide(color: Constants.primaryColor),
                          ),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor)
                          ),
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Constants.primaryColor),
                          )
                      ) ,
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLength: 1000,
                      maxLines: 2,
                      controller: productDescriptionController,
                      validator: validateDescription,
                      style: TextStyle(
                          fontSize: 17.0,
                          fontFamily: Constants.PrimaryFont
                      ),
                      decoration: InputDecoration(
                          labelText: 'အကြောင်းအရာ',
                          labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                          hintText: '',
                          enabledBorder: new OutlineInputBorder(
                            borderSide:new BorderSide(color: Constants.primaryColor),
                          ),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor)
                          ),
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Constants.primaryColor),
                          )
                      ) ,
                    ),
                    SizedBox(height: 10.0,),
                   productId=="" ?
                   DropdownButtonFormField<String>(
                      autovalidate: true,
                      decoration:  InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                          enabledBorder: new OutlineInputBorder(
                            borderSide:new BorderSide(color: Constants.primaryColor),
                          ),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor)
                          ),
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Constants.primaryColor),
                          )
                      ) ,
                      value:newCategory,
                      // value: categorySelected,
                      items: categoryList.map((label){
                       return DropdownMenuItem(
                          child: Text(
                            label,
                            style:
                            TextStyle(height: -0.0,color: Colors.black,fontFamily: Constants.PrimaryFont),
                          ),
                          value: label,
                        );
                      }
                         ).toList(),
                      onChanged: (value) {
                        // if(productDescription=="") {
                        //   setState(() => newCategory = value);
                        // }else{
                          setState(() { newCategory = value.toString();
                          print(newCategory);});
                          FocusScope.of(context).requestFocus(FocusNode());
                        // }
                      },
                    ):
                   DropdownButtonFormField<String>(
                     autovalidate: true,
                     decoration:  InputDecoration(
                         labelText: 'Category',
                         labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                         enabledBorder: new OutlineInputBorder(
                           borderSide:new BorderSide(color: Constants.primaryColor),
                         ),
                         focusedBorder: new OutlineInputBorder(
                             borderSide: new BorderSide(color: Constants.primaryColor)
                         ),
                         border: new OutlineInputBorder(
                           borderSide: new BorderSide(color: Constants.primaryColor),
                         )
                     ) ,
                     value:categorySelected,
                     // value: categorySelected,
                     items: categoryList.map((label){
                       return DropdownMenuItem(
                         child: Text(
                           label,
                           style:
                           TextStyle(height: -0.0,color: Colors.black,fontFamily: Constants.PrimaryFont),
                         ),
                         value: label,
                       );
                     }
                     ).toList(),
                     onChanged: (value) {
                       categorySelected = value.toString();
                      print(categorySelected);
                       FocusScope.of(context).requestFocus(FocusNode());
                     },
                   ),
                   productId==""?SizedBox(): SizedBox(height: 10.0,),
                    ///to show the price in the Stream builder
                    productId==""? SizedBox():Container(width: MediaQuery.of(context).size.width,child: Text('စျေးနူန်း',style: TextStyle(fontFamily: Constants.PrimaryFont),),),
                    productId==""?SizedBox():
                    Container(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirestoreService().getPrice('price',productId),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Something went wrong');
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            return Container(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: snapshot.data.documents.map((DocumentSnapshot document)
                                {
                                  return InkWell(
                                    onTap: (){
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      priceController.text=document.data()['price'];
                                      quantityController.text=document.data()["quantity"].toString();
                                      kindPrice=document.data()['price_kind'];
                                      unit= document.data()['unit'].toString();
                                      showAddBottomsheet(context,productId,document.data()['price_id'], unitList,kindList,document.data()['price']);
                                    },
                                      child: PriceCard(document.data()['price_kind'], document.data()['quantity'].toString(),document.data()['unit'].toString(), document.data()['price']));
                                }).toList(),
                              ),
                            );
                          }),
                    ),

                    SizedBox(height: 10.0,),
                    Container(
                      height: 50.0,
                      child: RaisedButton(
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_formKey.currentState.validate() ) {
                            if(productId == "" ) {
                              if(newCategory == ""){
                                ///validate Category
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  content: Text('data အပြည့်အစုံထည့်ပါ'),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                ));
                              }else{
                                print("validated");
                                productName = productNameController.text;
                                setState(() {
                                  productId = uuid.v4();
                                });
                                productDescription = productDescriptionController.text;
                                print("image" + productImage);
                                print("name" + productName);
                                print("description" + productDescription);
                                print("category" + newCategory);
                                print("id" + productId);

                                ProductModel product = ProductModel(
                                  productId:productId,
                                  productName: productName,
                                  productSearch: setSearchParam(productName),
                                  productImage: productImage,
                                  category:newCategory.toString(),
                                  discount: "",
                                  description: productDescriptionController.text,
                                );
                                categorySelected=newCategory;
                                Future.delayed(Duration(seconds: 1), (){
                                  FirestoreService().addProduct("product", product);
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('product အသစ် ထည့်သွင်းပြီးပါပြီ'),
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.greenAccent,
                                  ));
                                });
                                setState(() {
                                  startLoading=false;
                                });
                              }
                            }else {
                              setState(() {
                                startLoading=true;
                              });
                              productName = productNameController.text;
                              productDescription = productDescriptionController.text;
                              print("image" + productImage);
                              print("name" + productName);
                              print("description" + productDescription);
                              print("category" + categorySelected);
                              print("id" + productId);
                              ProductModel product = ProductModel(
                                productId:productId,
                                productName: productName,
                                productSearch: setSearchParam(productName),
                                productImage: productImage,
                                category:categorySelected,
                                discount: "",
                                description: productDescriptionController.text,
                              );
                              Future.delayed(Duration(seconds: 1), (){
                                FirestoreService().editProduct("product", product);
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  content: Text('အောင်မြင်ပါသည်'),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.greenAccent,
                                ));
                              });
                              setState(() {
                                startLoading=false;
                              });
                            }
                          }else{
                              _scaffoldKey.currentState
                                  .showSnackBar(SnackBar(
                                content: Text('data အပြည့်အစုံထည့်ပါ'),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                              ));
                          }
                   },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
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
                            child: Text(productId==""? 'Product ထည့်မည်':"ပြင်ဆင်မည်",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                     productId==""?SizedBox(height: 10.0,):Container(
                     height: 50.0,
                     child: RaisedButton(
                       onPressed: () async {
                         FocusScope.of(context).requestFocus(FocusNode());
                         showAddBottomsheet(context,productId,"", unitList,kindList,"");
                         priceController.text="";
                         quantityController.text="";
                       },
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
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
                           child: Text("စျေးနူန်းသတ်မှတ်မည်",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                         ),
                       ),
                     ),
                   ),
                     productId==""?SizedBox():SizedBox(height: 10,),
                   productId==""?SizedBox(height: 10,):
                   RaisedButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Warning!',
                                style: new TextStyle(
                                    fontSize: 23.0, color: Constants.primaryColor)),
                            content: Text( 'ဖျက်ရန် သေချာပါသလား',style: TextStyle(fontFamily: Constants.PrimaryFont),),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('မဖျက်ပါ',
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.right),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('ဖျက်မည်',
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.right),
                                onPressed: () {

                                  setState(() {
                                    startLoading=true;
                                  });
                                  FirestoreService().remove('product', productId);
                                  FirebaseStorageService().DeletePhoto(productImage);
                                  setState(() {
                                    startLoading=false;
                                  });
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('အောင်မြင်ပါသည်'),
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.greenAccent,
                                  ));
                                  Future.delayed(Duration(seconds: 1), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductPage())));

                                },
                              )
                            ],
                          ),
                        );

                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text('Delete', style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),
                          ),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: Constants.primaryColor,
                          width: 1,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.circular(80)),
                    ),
                  ],
                ),
              ),
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
    if(productImage=="") {
      productImage =
      await FirebaseStorageService().UploadPhoto('product', slideImage);
    }else{
      var newImage=await FirebaseStorageService().EditPhoto(productImage, 'product', slideImage);
      productImage=newImage.toString();
    }
    print(productImage);
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
    if(productImage=="") {
      productImage = await FirebaseStorageService().UploadPhoto('product', slideImage);
    }else{
      var newImage=await FirebaseStorageService().EditPhoto(productImage, 'product', slideImage);
      productImage=newImage.toString();
    }
    setState(() {
      loading=false;
    });
  }


  ///
  ///**********         **
  ///**      **
  ///**      ** **   *  **  ******  *******
  ///**      ** **  *   **  **      **   **
  ///********** ****    **  **      *******
  ///**         ***     **  **      **
  ///**         ***     **  ******  *******
      ///to add price
  showAddBottomsheet(BuildContext context,String productId,String document,List<String> unitlist,List<String> kindlist,String oldPrice){
    var uuid=Uuid();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        enableDrag: false,
      builder: (context){
          return SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKeyBottom,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10.0,),
                      DropdownButtonFormField<String>(
                        autovalidate: true,
                        decoration:  InputDecoration(
                            labelText: 'အမျိုးအစား',
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                            enabledBorder: new OutlineInputBorder(
                              borderSide:new BorderSide(color: Constants.primaryColor),
                            ),
                            focusedBorder: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Constants.primaryColor)
                            ),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor),
                            )
                        ) ,
                        value:kindPrice,
                        // value: categorySelected,
                        items: kindlist.map((label){
                          return DropdownMenuItem(
                            child: Text(
                              label,
                              style:
                              TextStyle(height: -0.0,color: Colors.black,fontFamily: Constants.PrimaryFont),
                            ),
                            value: label,
                          );
                        }
                        ).toList(),
                        onChanged: (value) {
                          // if(productDescription=="") {
                          //   setState(() => newCategory = value);
                          // }else{
                          setState(() { kindPrice = value.toString();
                          print(kindPrice);});
                          FocusScope.of(context).requestFocus(FocusNode());
                          // }
                        },
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width:MediaQuery.of(context).size.width /1.7,
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  fontFamily: Constants.PrimaryFont
                              ),
                              decoration: InputDecoration(
                                  labelText: 'အရေအတွက်',
                                  labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide:new BorderSide(color: Constants.primaryColor),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                      borderSide: new BorderSide(color: Constants.primaryColor)
                                  ),
                                  border: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Constants.primaryColor),
                                  )
                              ) ,
                            ),
                          ),
                          Container(
                            width:MediaQuery.of(context).size.width /3 ,
                            child: DropdownButtonFormField<String>(
                              decoration:  InputDecoration(
                                  labelText: 'unit',
                                  labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide:new BorderSide(color: Constants.primaryColor),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                      borderSide: new BorderSide(color: Constants.primaryColor)
                                  ),
                                  border: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Constants.primaryColor),
                                  )
                              ) ,
                              value:unit,
                              // value: categorySelected,
                              items: unitlist.map((label){
                                return DropdownMenuItem(
                                  child: Text(
                                    label,
                                    style:
                                    TextStyle(height: -0.0,color: Colors.black,fontFamily: Constants.PrimaryFont),
                                  ),
                                  value: label,
                                );
                              }
                              ).toList(),
                              onChanged: (value) {
                                unit = value.toString();
                                print(unit);
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'စျေးနူန်း',
                            suffix: Text('ကျပ်',style:TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont),),
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            enabledBorder: new OutlineInputBorder(
                              borderSide:new BorderSide(color: Constants.primaryColor),
                            ),
                            focusedBorder: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Constants.primaryColor)
                            ),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor),
                            )
                        ) ,
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisSize:MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: document==""? MediaQuery.of(context).size.width/1.1 : MediaQuery.of(context).size.width/2.2,
                            child: RaisedButton(
                              onPressed: () async {
                                String priceID=uuid.v4();
                                print(priceID);

                                if(quantityController.text=="" || priceController.text=="" || kindPrice=="" || unit==""){
                                  print('no data');
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ToastNoContext(),
                                  ));

                                }else{
                                  if(document=="") {
                                    print('quantity'+quantityController.text);
                                    print('price'+priceController.text);
                                    print('kind'+kindPrice);
                                    print('unit'+unit);
                                    print('productId'+productId);
                                    PriceModel pricemodel = PriceModel(
                                        id: priceID,
                                        unit: unit,
                                        kind: kindPrice,
                                        price: priceController.text,
                                        quantity:int.parse(quantityController.text)
                                    );
                                    FirestoreService().addPrice(
                                        'price', productId, pricemodel);
                                    document=priceID;
                                  }else{
                                    print('quantity'+quantityController.text);
                                    print('price'+priceController.text);
                                    print('kind'+kindPrice);
                                    print('unit'+unit);
                                    print('productId'+productId);

                                    PriceModel pricemodel = PriceModel(
                                        id: document,
                                        unit: unit,
                                        kind: kindPrice,
                                        price: priceController.text,
                                        quantity: int.parse(quantityController.text)
                                    );
                                    FirestoreService().editPrice(
                                        'price', productId, pricemodel);

                                    UpdatePriceModel updatePriceModel=UpdatePriceModel(
                                      id:uuid.v4(),
                                      kind: kindPrice,
                                      quantity: int.parse(quantityController.text),
                                      unit: unit,
                                      prodctName: productName,
                                      productPhoto: productImage,
                                      oldPrice:oldPrice,
                                      newPrice: priceController.text,
                                      createdDate: DateTime.now().millisecondsSinceEpoch
                                    );
                                    FirestoreService().addUpdatedPrice(updatePriceModel);

                                  }
                                }

                                Navigator.of(context).pop();
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
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
                                  child: Text( document==""?'ထည့်သွင်းမည်':"ပြင်ဆင်မည်",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                                ),
                              ),
                            ),
                          ),
                          document==""? SizedBox(width: 0.0,):SizedBox(width: 10,),
                          document==""? SizedBox(width: 0.0,): Container(
                            width: MediaQuery.of(context).size.width/2.2,
                            child: RaisedButton(
                              onPressed: () async {
                                FirestoreService().removePrice('price', productId, document);
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
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
                                  child: Text( "Delete",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.0,),
                      RaisedButton(
                        onPressed: (){
                          Navigator.pop(context);
                          setState(() {
                            FocusScope.of(context).requestFocus(FocusNode());
                            priceController.text="";
                            quantityController.text="";
                          });
                        },
                        padding: EdgeInsets.all(0.0),
                        child: Ink(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Container(
                            constraints: BoxConstraints(minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text('Cancel', style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),
                            ),
                          ),
                        ),
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(
                            color: Constants.primaryColor,
                            width: 1,
                            style: BorderStyle.solid
                        ), borderRadius: BorderRadius.circular(80),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      }
    );
  }
}
