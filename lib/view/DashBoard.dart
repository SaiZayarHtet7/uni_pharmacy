import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/route_manager.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'file:///C:/Users/MSI/freelanceProjects/uni_pharmacy/lib/view/chat/ChatBox.dart';
import 'package:uni_pharmacy/view/EditCategory.dart';
import 'package:uni_pharmacy/view/EditSlide.dart';
import 'package:uni_pharmacy/view/EditUnit.dart';
import 'package:uni_pharmacy/view/LoginPage.dart';
import 'package:uni_pharmacy/view/OrderPage.dart';
import 'package:uni_pharmacy/view/ProductPage.dart';
import 'package:uni_pharmacy/view/Register.dart';
import 'package:uni_pharmacy/view/VoucherPage.dart';
import 'package:uni_pharmacy/view/noti/NotiPage.dart';


var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  CarouselController buttonCarouselController = CarouselController();
  int _current=0;
  List<String> imgList = [];
  bool loading;
  int unitCount,userCount,categoryCount,productCount,messageNotiCount,notiCount;
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
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Text(message['notification']['title'],style: TextStyle(color: Constants.primaryColor,fontSize: 20,fontFamily: Constants.PrimaryFont),),
        //         SizedBox(height: 10.0,),
        //         Text(message['notification']['body'],style: TextStyle(color: Colors.black,fontSize: 15,fontFamily: Constants.PrimaryFont), ),
        //       ],
        //     ),
        //     actions: <Widget>[
        //       FlatButton(
        //         child: Text('Ok',style: TextStyle(color:Constants.thirdColor,fontSize: 15,fontFamily: Constants.PrimaryFont),),
        //         onPressed: () => Navigator.of(context).pop(),
        //       ),
        //     ],
        //   ),
        // );
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
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'default',
      msg["notification"]["title"].toString(),
      msg["notification"]["body"].toString(),);
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidChannelSpecifics, iOSChannelSpecifics);

    FlutterLocalNotificationsPlugin localNotifPlugin =
    new FlutterLocalNotificationsPlugin();
    var android = new AndroidNotificationDetails(
        'id', 'channel ', 'description',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('noti_sound'),
        showWhen: true,
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        1, msg["notification"]["title"].toString(),msg["notification"]["body"].toString() , platform);
    await localNotifPlugin.show(
        1,
        msg["notification"]["title"].toString(),
        msg["notification"]["body"].toString(),
        platformChannelSpecifics
    );
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

    FirebaseFirestore.instance.collection("user").where("status",isEqualTo: 'unread').where('is_new_chat',isEqualTo: 'old').get().then((value){
      messageNotiCount= value.docs.length;
      print('number of unread '+messageNotiCount.toString());
    });

    FirebaseFirestore.instance.collection("noti").where("noti_type",isEqualTo: 'unread').get().then((value){
      notiCount= value.docs.length;
      print('number of unread '+notiCount.toString());
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


    return  DoubleBack(
        message:"Press back again to close",
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer:new Drawer(
              child: HeaderOnly()),
          appBar: new AppBar(
            shadowColor: Constants.thirdColor,
            automaticallyImplyLeading: false,
            actions: [

              Badge(
          position:BadgePosition(top: 4,end: -5) ,
          badgeContent: Text(notiCount.toString()),
                showBadge: notiCount==0 || notiCount==null? false :true,
                child: IconButton(icon:
                Icon(Icons.notifications,color: Colors.black,),onPressed: () async{
                  // await FirebaseFirestore.instance.
                  //     collection('noti').get().then((value) => value
                  // ));
                  setState(() {
                    notiCount=0;
                  });

                  FirebaseFirestore.instance.collection('noti').get().then((value){
                    value.docs.forEach((element) {element.reference.update(<String,dynamic>{'noti_type':'read'}); });
                  });

                  // db.collection("cities").get().then(function(querySnapshot) {
                  // querySnapshot.forEach(function(doc) {
                  // doc.ref.update({
                  // capital: true
                  // });
                  // });
                  // });

                  // await snapshots.forEach((document) async {
                  //   document.reference.updateData(<String, dynamic>{
                  //
                  //   });
                  // })

                  ///Logics for notification
                  Get.to(NotiPage());
                },),
              ),
              SizedBox(width: 10.0,),

              InkWell(child:messageNotiCount==0||messageNotiCount==null ?
              Image.asset('assets/image/menu.png',width: 30,):
                Badge(position:BadgePosition(top: 4,end: -5) ,
                  badgeContent: Text(messageNotiCount.toString()),child:Image.asset('assets/image/menu.png',width: 30,) , ),onTap: (){
                ///Logics for notification
                _scaffoldKey.currentState.openEndDrawer();
              },),
              SizedBox(width: 10.0,),
            ],
            iconTheme: new IconThemeData(color: Constants.primaryColor),
            toolbarHeight: 70,
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('ပင်မစာမျက်နှာ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont),)),
                Row(children: [
                  SizedBox(width: 10.0,)
                ],)
              ],
            ),backgroundColor: Colors.white,),
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
                            child: Text('အလှဓါတ်ပုံများ ပြင်ဆင်မည်',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
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
                                onTap:(){
                                  Get.to(ProductPage(),
                                );},
                                  child:  CardIcon(Icon(Icons.add,size: 50,color: Colors.white,), 'ဆေးပစ္စည်းများ','$productCount','#FD7F2C','#FD9346'),
                              ),
                              InkWell(
                                onTap: () =>Get.to(EditCategory()),
                                  child: CardIcon(Icon(Icons.category,size: 50,color: Colors.white,), 'အမျိုးအစားများ','$categoryCount','#48b1bf','#06beb6')),
                            ]
                          ),
                          TableRow(
                              children: [
                                InkWell(
                                    onTap: ()=> Get.to( EditUnt()),
                                    child: CardIcon(Icon(Icons.ac_unit,size: 50,color: Colors.white,), 'ယူနစ်များ','$unitCount','#56ab2f','#43cea2')),
                                InkWell(
                                    onTap: ()=>Get.to(Register()),
                                    child: CardIcon(Icon(Icons.account_circle,size: 50,color: Colors.white,), 'မှတ်ပုံတင်ရန်','$userCount','#F7971E','#FFD200')),
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


class HeaderOnly extends StatefulWidget {
  @override
  _HeaderOnlyState createState() => _HeaderOnlyState();
}

class _HeaderOnlyState extends State<HeaderOnly> {
  String userName;
  String userPhoto;
  String phoneNumber;
  String address;
  String userId;
  bool loading;
  final picker = ImagePicker();
  File userImage;
  int messageNotiCount;

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    loading=true;
    super.initState();
  }

  fetchData() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    userName= pref.getString('user_name');
    userPhoto= pref.getString('user_photo');
    phoneNumber= pref.getString('phone_number');
    address= pref.getString('address');
    userId= pref.getString('uid');
    FirebaseFirestore.instance.collection("user").where("status",isEqualTo: 'unread').where('is_new_chat',isEqualTo: 'old').get().then((value){
      setState(() {
        messageNotiCount= value.docs.length;
      });
      print('number of unread '+messageNotiCount.toString());
    });
    setState(() {
      loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: messageNotiCount==null? Center(child:CircularProgressIndicator()):  ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
              color: Constants.primaryColor
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loading==true? Center(child: CircularProgressIndicator()):
              CachedNetworkImage(
                imageUrl:"https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.jpg?alt=media&token=cc9cd6ad-d5c0-4326-98bb-2397166ece6b",
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              SizedBox(height: 10.0,),
              Text("UNI Pharmacy",style: TextStyle(color:Colors.white,fontSize: 16,fontFamily: Constants.PrimaryFont),)
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text("Menu",style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 16,fontWeight: FontWeight.bold),)),
        SizedBox(height: 10.0,),
        ///home
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/circular_home.png')),
            title: Text(
              "ပင်မစာမျက်နှာ",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///order
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/order.png')),
          title: Text(
            "အော်ဒါများ",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.of(context).pop();
            Get.to(OrderPage());
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///vouchers
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/voucher.png')),
          title: Text(
            "အ‌ဝယ်ဘောက်ချာများ",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.of(context).pop();
            Get.to(VoucherPage());
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///chat
       messageNotiCount==0 || messageNotiCount==null? ListTile(
         leading: Container(
             padding: EdgeInsets.all(5.0),
             child: Image.asset('assets/image/message.png')),
         title: Text(
           "စကားပြောရန်",
           style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
         ),
         onTap: () {
           Navigator.of(context).pop();
           Get.to(ChatBox());
         },
       ) : Badge(
         position: BadgePosition(top: -5,end: 30),
         badgeContent: Text(messageNotiCount.toString()),
         child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/message.png')),
            title: Text(
              "စကားပြောရန်",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Get.to(ChatBox());
            },
          ),
       ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        SizedBox(height: 30.0,),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text("General",style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 16,fontWeight: FontWeight.bold),)),
        SizedBox(height: 10.0,),

        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/smartphone.png')),
          title: Text(
            "အကောင့်မှထွက်ရန်",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0,color: Constants.primaryColor),
          ),
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text( 'Account မှထွက်ရန် သေချာပြီလား?',
                    style: new TextStyle(
                        fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ထွက်မည်',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Constants.primaryColor,
                            fontFamily: Constants.PrimaryFont
                        ),
                        textAlign: TextAlign.right),
                    onPressed: () async {
                      SharedPreferences pref= await SharedPreferences .getInstance();
                      await FirebaseAuth.instance.signOut();
                      FirebaseAuth.instance
                          .authStateChanges()
                          .listen((User user) {
                        if (user == null) {
                          print('User is currently signed out!');
                          pref.clear();
                          Get.offAll(LoginPage());
                        } else {
                          print('User is signed in!');
                        }
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('မထွက်ပါ',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Constants.primaryColor,
                            fontFamily: Constants.PrimaryFont
                        ),
                        textAlign: TextAlign.right),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => HomePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
      ]),
    );
  }
}
