
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/LoginPage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: Text('ပြင်ဆင်ရန်'),
        backgroundColor: Constants.primaryColor,),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10.0,),
                  Container(
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: () async {
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
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => LoginPage()),
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
                          child: Text('Logout',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
