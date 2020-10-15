import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/EditCategory.dart';
import 'package:uni_pharmacy/view/EditSlide.dart';
import 'package:uni_pharmacy/view/EditUnit.dart';
import 'package:uni_pharmacy/view/ProductPage.dart';
import 'package:uni_pharmacy/view/Register.dart';


var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  CarouselController buttonCarouselController = CarouselController();
  int _current=0;
  List<String> imgList = [];
  bool loading;
  int unitCount,userCount,categoryCount,productCount;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


@override
  void initState() {
    // TODO: implement initState
  setState(() {
    Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    var initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOs);
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotification(message);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message['notification']['title'],style: TextStyle(color: Constants.primaryColor,fontSize: 20,fontFamily: Constants.PrimaryFont),),
                SizedBox(height: 10.0,),
                Text(message['notification']['body'],style: TextStyle(color: Colors.black,fontSize: 15,fontFamily: Constants.PrimaryFont), ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok',style: TextStyle(color:Constants.thirdColor,fontSize: 15,fontFamily: Constants.PrimaryFont),),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProductPage()));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProductPage()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

      },
    );
    loading=true;

  });

  loading=true;
  fetchData();
    super.initState();

  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
        'id', 'channel ', 'description',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('noti_sound'),
        priority: Priority.High, importance: Importance.Max);

    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, msg["notification"]["title"].toString(),msg["notification"]["body"].toString() , platform);
  }

  fetchData() async {
    FirebaseFirestore.instance.collection("slide").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        imgList.add(result.data()['slide'].toString());
        print(imgList);
      });
      setState(() {
        loading=false;
      });
    });

    FirebaseFirestore.instance.collection("unit").get().then((value){
     unitCount= value.docs.length;
     print('number of unit'+unitCount.toString());
    });

    FirebaseFirestore.instance.collection("user").get().then((value){
      userCount= value.docs.length;
      print('number of user'+userCount.toString());
    });


    FirebaseFirestore.instance.collection("category").get().then((value){
      categoryCount= value.docs.length;
      print('number of category'+categoryCount.toString());
    });

    FirebaseFirestore.instance.collection("product").get().then((value){
      productCount= value.docs.length;
      print('number of category'+productCount.toString());
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: Text('ပင်မစာမျက်နှာ'),backgroundColor: Constants.primaryColor,),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 5.0,),
                  Stack(
                    children: [
                     loading ==true? Center(child: CircularProgressIndicator()): CarouselSlider(
                        items: imgList.map((item) => Container(
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:item, fit: BoxFit.cover,height: 250,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  Container(padding: EdgeInsets.all(108),height: 50.0,
                                      child: CircularProgressIndicator( value: downloadProgress.progress)),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        )).toList(),
                        carouselController: buttonCarouselController,
                        options: CarouselOptions(
                            onPageChanged: (index,reason){
                              setState(() {
                                _current=index;
                              });
                            },
                            autoPlay: true,
                            height: 250,
                            enlargeCenterPage: false,
                            viewportFraction: 1,
                            aspectRatio: 1.5,
                            initialPage: 0,
                            scrollDirection: Axis.horizontal
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                  ///For editing Slide Image
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0),
                    height: 40.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => EditSlide()),
                        );
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
                          child: Text('Change Slide Image',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 20.0,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(height:10.0,color: Colors.black,),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            InkWell(
                              onTap:()=>Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductPage()),
                              ),
                                child:  CardIcon(Icon(Icons.add,size: 50,color: Colors.white,), 'Add Product','$productCount','#FD7F2C','#FD9346'),
                            ),
                            InkWell(
                              onTap: () =>Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditCategory()),
                              ),
                                child: CardIcon(Icon(Icons.category,size: 50,color: Colors.white,), 'Add Category','$categoryCount','#48b1bf','#06beb6')),
                          ]
                        ),
                        TableRow(
                            children: [
                              InkWell(
                                  onTap: ()=> Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditUnt()),
                                  ),
                                  child: CardIcon(Icon(Icons.ac_unit,size: 50,color: Colors.white,), 'Add Unit','$unitCount','#56ab2f','#43cea2')),
                              InkWell(
                                  onTap: ()=> Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Register()),
                                  ),
                                  child: CardIcon(Icon(Icons.account_circle,size: 50,color: Colors.white,), 'Register','$userCount','#F7971E','#FFD200')),
                            ]
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget CardIcon(Icon icon,String text,String number,String start,String End){
  return Card(
    elevation: 5,
    color: Constants.thirdColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomRight: Radius.circular(20),bottomLeft: Radius.circular(5),topRight: Radius.circular(5)),
    ),
    child: Ink(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Hexcolor('$start'),Hexcolor('$End'),],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomRight: Radius.circular(20),bottomLeft: Radius.circular(5),topRight: Radius.circular(5)),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont,fontSize: 18),textAlign: TextAlign.start,),
          SizedBox(height: 20.0,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [number!='null'?Text('$number',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont,fontSize: 25),):CircularProgressIndicator(backgroundColor: Colors.white,),icon,],),
          ),
          SizedBox(height: 10.0,),
        ],
  ),
      ),
    ),);
  }

}
