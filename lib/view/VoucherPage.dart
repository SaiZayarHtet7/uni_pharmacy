import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/chat/ChatBox.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uni_pharmacy/view/LoginPage.dart';
import 'package:uni_pharmacy/view/OrderPage.dart';
import 'package:uni_pharmacy/view/Voucher/VoucherOrder.dart';
import 'package:uni_pharmacy/view/Widget/TitleTextColor.dart';
import 'package:uni_pharmacy/view/Widget/VoucherCard.dart';
import 'package:uni_pharmacy/view/noti/NotiPage.dart';




class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  bool loading;
  String userName;
  int current = 0;
  List<String> imgList = [];
  int prepareOrderCount,deliverOrderCount,messageNotiCount,notiCount;

  fetchData() async {
      loading = true;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString("user_name");
    });
    FirebaseFirestore.instance.collection("voucher").where('status',isEqualTo: Constants.orderPrepare).get().then((value){
      setState(() {
        prepareOrderCount = value.docs.length;
      });
      print('number of prepare order'+prepareOrderCount.toString());
    });
      FirebaseFirestore.instance.collection("noti").where("noti_type",isEqualTo: 'unread').get().then((value){
        notiCount= value.docs.length;
        print('number of unread '+notiCount.toString());
      });
      FirebaseFirestore.instance.collection("user").where("status",isEqualTo: 'unread').where('is_new_chat',isEqualTo: 'old').get().then((value){
        setState(() {
          messageNotiCount= value.docs.length;
        });
        print('number of unread '+messageNotiCount.toString());
      });
    FirebaseFirestore.instance.collection("voucher").where('status',isEqualTo: Constants.orderDeliver).get().then((value){
      setState(() {
        deliverOrderCount = value.docs.length;
      });
      print('number of deliver order'+deliverOrderCount.toString());
    });
    setState(() {
      loading=false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    ///Declaration
    return  Scaffold(
        key: _scaffoldKey,
        endDrawer: new Drawer(
            child: HeaderOnly()),
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Constants.thirdColor,
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
                  child: Text('ဘောက်ချာများ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont),)),
              Row(children: [
                SizedBox(width: 10.0,)
              ],)
            ],
          ),backgroundColor: Colors.white,),
        body: SafeArea(
          child: loading==true? Container(height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()),): SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  deliverOrderCount ==0 || deliverOrderCount==null ? SizedBox(height: 20.0,): Container(
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width:75,
                            child: Text('ရက်စွဲ',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont),)),
                        Text('ဘောက်ချာအမှတ်',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont),),
                        Container(
                          width: 120,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),
                  ),
                  deliverOrderCount==0 || deliverOrderCount==null ? SizedBox(height: 10.0,): StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('voucher').where("status",isEqualTo: Constants.orderDeliver).orderBy('voucher_number').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if(snapshot.hasData){
                          return ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data.documents.map((DocumentSnapshot document) {
                              return InkWell(
                                  onTap: (){
                                    Get.to(VoucherOrder(document.data()['voucher_id'],document.data()['voucher_number'].toString()));
                                  },
                                  child: VoucherCard(document.data()['date_time'], document.data()['voucher_number'].toString(), document.data()['status']));
                            }).toList(),
                          );
                        }else{
                          return TitleTextColor("No data", Constants.thirdColor);
                        }
                      }),
                  deliverOrderCount==0 || deliverOrderCount==null ? Center(child: SizedBox(child: Text('ဘောက်ချာ မရှိသေးပါ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16),),)):SizedBox(),
                ],
              ),
            ),
          ),
        ),
      );

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
      child:messageNotiCount==null? Center(child:CircularProgressIndicator()):  ListView(children: <Widget>[
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
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/circular_home.png')),
            title: Text(
              "ပင်မစာမျက်နှာ",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Get.offAll(DashBoard());
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
        Container(
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child:  ClipOval(child: Image.asset('assets/image/order.png'))),
            title: Text(
              "အော်ဒါများ",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Get.to(OrderPage());
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
        ///vouchers
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: ClipOval(child: Image.asset('assets/image/voucher.png'))),
            title: Text(
              "အ‌ဝယ်ဘောက်ချာများ",
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