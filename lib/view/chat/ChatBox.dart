import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uni_pharmacy/view/LoginPage.dart';
import 'package:uni_pharmacy/view/OrderPage.dart';
import 'package:uni_pharmacy/view/VoucherPage.dart';
import 'package:intl/intl.dart';
import 'package:uni_pharmacy/view/chat/ChatDetail.dart';
import 'package:uni_pharmacy/view/chat/LatestChat.dart';
import 'package:uni_pharmacy/view/noti/NotiPage.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  String searchName;
  int notiCount;

  Future<bool> _onWillPop() async {
    print('hellp');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application မှထွက်ရန် သေချာပြီလား?',
            style: new TextStyle(
                fontSize: 20.0,
                color: Constants.thirdColor,
                fontFamily: Constants.PrimaryFont)),
        actions: <Widget>[
          FlatButton(
            child: Text('ထွက်မည်',
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Constants.primaryColor,
                    fontFamily: Constants.PrimaryFont),
                textAlign: TextAlign.right),
            onPressed: () async {
              SystemNavigator.pop();
            },
          ),
          FlatButton(
            child: Text('မထွက်ပါ',
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Constants.primaryColor,
                    fontFamily: Constants.PrimaryFont),
                textAlign: TextAlign.right),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  fetchData() async {
    FirebaseFirestore.instance
        .collection("noti")
        .where("noti_type", isEqualTo: 'unread')
        .get()
        .then((value) {
      setState(() {
        notiCount = value.docs.length;
      });

      print('number of unread ' + notiCount.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    Firebase.initializeApp();
    fetchData();
    super.initState();
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = new DateFormat.jm();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: new Drawer(child: HeaderOnly()),
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            shadowColor: Constants.thirdColor,
            actions: [
              Badge(
                position: BadgePosition(top: 4, end: -5),
                badgeContent: Text(notiCount.toString()),
                showBadge: notiCount == 0 || notiCount == null ? false : true,
                child: IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    // await FirebaseFirestore.instance.
                    //     collection('noti').get().then((value) => value
                    // ));
                    setState(() {
                      notiCount = 0;
                    });

                    FirebaseFirestore.instance
                        .collection('noti')
                        .get()
                        .then((value) {
                      value.docs.forEach((element) {
                        element.reference
                            .update(<String, dynamic>{'noti_type': 'read'});
                      });
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotiPage()),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              InkWell(
                child: Image.asset(
                  'assets/image/menu.png',
                  width: 30,
                ),
                onTap: () {
                  _scaffoldKey.currentState.openEndDrawer();
                },
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
            iconTheme: new IconThemeData(color: Constants.primaryColor),
            toolbarHeight: 70,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'စကားပြောခန်း',
                      style: TextStyle(
                          color: Constants.primaryColor,
                          fontFamily: Constants.PrimaryFont),
                    )),
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    )
                  ],
                )
              ],
            ),
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
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
                          borderSide:
                              new BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              new BorderSide(color: Colors.black, width: 1),
                        ),
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              new BorderSide(color: Colors.black, width: 1),
                        )),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 70),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: searchName == "" || searchName == null
                        ? FirebaseFirestore.instance
                            .collection('user')
                            .where('is_new_chat', isEqualTo: "old")
                            .orderBy('final_chat_date_time', descending: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('user')
                            .orderBy('final_chat_date_time', descending: true)
                            .where('search_name', arrayContains: searchName)
                            .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return new ListView(
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          return Column(
                            children: [
                              new ListTile(
                                  hoverColor: Constants.thirdColorAccent,
                                  selectedTileColor: Constants.thirdColorAccent,
                                  focusColor: Constants.thirdColorAccent,
                                  onTap: () {
                                    print("hello");
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(document.data()['uid'])
                                        .update({'status': 'read'})
                                        .then((value) => print("User Updated"))
                                        .catchError((error) => print(
                                            "Failed to update user: $error"));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatDetail(
                                                document.data()['user_name'],
                                                document.data()['uid'],
                                                document
                                                    .data()['profile_image'])));
                                  },
                                  tileColor:
                                      document.data()['status'] == "unread"
                                          ? Colors.amber[100]
                                          : Colors.transparent,
                                  leading: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Constants.thirdColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: document.data()['profile_image'] ==
                                            ""
                                        ? Container(
                                            width: 100,
                                            height: 100,
                                            child: Icon(
                                              Icons.account_circle,
                                              color: Constants.thirdColor,
                                              size: 50,
                                            ))
                                        : Container(
                                            width: 100.0,
                                            height: 100.0,
                                            child: CachedNetworkImage(
                                              imageUrl: document
                                                  .data()['profile_image'],
                                              fit: BoxFit.cover,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 100.0,
                                                height: 100.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 2),
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 1,
                                                      )),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                  ),
                                  trailing: Text(readTimestamp(
                                      document.data()['final_chat_date_time'])),
                                  title: new Text(
                                    document.data()['user_name'],
                                    style: TextStyle(
                                        color: Constants.primaryColor),
                                  ),
                                  subtitle: LatestChat(document.data()['uid'],
                                      document.data()['sender'])),
                              Divider(
                                endIndent: 10,
                                indent: 10,
                                color: Colors.grey,
                                thickness: 1,
                                height: 3,
                              )
                            ],
                          );
                        }).toList(),
                      );
                    },
                  )),
            ],
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

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    loading = true;
    super.initState();
  }

  fetchData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    userName = pref.getString('user_name');
    userPhoto = pref.getString('user_photo');
    phoneNumber = pref.getString('phone_number');
    address = pref.getString('address');
    userId = pref.getString('uid');
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Constants.primaryColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loading == true
                  ? Center(child: CircularProgressIndicator())
                  : CachedNetworkImage(
                      imageUrl:
                          "https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.jpg?alt=media&token=cc9cd6ad-d5c0-4326-98bb-2397166ece6b",
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
                      placeholder: (context, url) => Container(
                          width: 80.0,
                          height: 80.0,
                          child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "UNI Pharmacy",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: Constants.PrimaryFont),
              )
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "Menu",
              style: TextStyle(
                  fontFamily: Constants.PrimaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 10.0,
        ),

        ///home
        Container(
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/circular_home.png')),
            title: Text(
              "ပင်မစာမျက်နှာ",
              style: new TextStyle(
                  fontFamily: Constants.PrimaryFont, fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
                child: ClipOval(child: Image.asset('assets/image/order.png'))),
            title: Text(
              "အော်ဒါများ",
              style: new TextStyle(
                  fontFamily: Constants.PrimaryFont, fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => OrderPage()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        ///vouchers
        Container(
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child:
                    ClipOval(child: Image.asset('assets/image/voucher.png'))),
            title: Text(
              "အ‌ဝယ်ဘောက်ချာများ",
              style: new TextStyle(
                  fontFamily: Constants.PrimaryFont, fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => VoucherPage()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        ///chat
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child:
                    ClipOval(child: Image.asset('assets/image/message.png'))),
            title: Text(
              "ရောင်းသူနှင့် စကားပြောရန်",
              style: new TextStyle(
                  fontFamily: Constants.PrimaryFont, fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        SizedBox(
          height: 30.0,
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "General",
              style: TextStyle(
                  fontFamily: Constants.PrimaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont,
                fontSize: 14.0,
                color: Constants.primaryColor),
          ),
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Account မှထွက်ရန် သေချာပြီလား?',
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Constants.thirdColor,
                        fontFamily: Constants.PrimaryFont)),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ထွက်မည်',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Constants.primaryColor,
                            fontFamily: Constants.PrimaryFont),
                        textAlign: TextAlign.right),
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await FirebaseAuth.instance.signOut();
                      FirebaseAuth.instance
                          .authStateChanges()
                          .listen((User user) {
                        if (user == null) {
                          print('User is currently signed out!');
                          pref.clear();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
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
                            fontFamily: Constants.PrimaryFont),
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
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
