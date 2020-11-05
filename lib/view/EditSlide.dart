import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uuid/uuid.dart';

class EditSlide extends StatefulWidget {
  @override
  _EditSlideState createState() => _EditSlideState();
}

class _EditSlideState extends State<EditSlide> {
  final picker = ImagePicker();
  File slideImage;
  var uuid=Uuid();
  bool loading;

  @override
  void initState() {
    // TODO: implement initState
    loading=false;
    super.initState();
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
    setState(() {
      loading=true;
    });
    await FirebaseStorageService().UploadSlidePhoto('slide', slideImage);
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
    await FirebaseStorageService().UploadSlidePhoto('slide', slideImage);
    setState(() {
      loading=false;
    });

  }


  Future<bool> _onWillPop() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard()));
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(appBar:AppBar(
        automaticallyImplyLeading: false,
        title: Text('အလှဓါတ်ပုံများ',),backgroundColor: Constants.primaryColor,
      leading: IconButton(
        icon:Icon( Icons.arrow_back_ios_rounded),
        onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard()))
      ),),
          body: SafeArea(
            child:Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().get('slide'),
                    builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                      if(snapshot.hasError){
                        return Text('Something went wrong in slide');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,));
                      }
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: ListView(
                          children: snapshot.data.documents.map((DocumentSnapshot document)
                              {
                            return Column(
                              children: [
                                new Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Colors.white,
                                  elevation:5,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:document.data()['slide'], fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                                              Container(
                                                  child: CircularProgressIndicator( value: downloadProgress.progress)),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                       SizedBox(height: 15,),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal:20.0),
                                          height: 40.0,
                                          child: RaisedButton(
                                            onPressed: () async{
                                             await FirestoreService().remove('slide',document.data()['id'] );
                                             await FirebaseStorageService().DeletePhoto(document.data()['slide']);
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
                                                child: Text('ဖျက်မည်',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height: 20.0,)
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                ),
                Center(
                  child:Visibility(
                      visible: loading,
                      child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)),
                )
              ],
            )
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _onButtonPressed_for_image(context);
          },
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Constants.primaryColor,
        ),
      ),
    );
  }
}
