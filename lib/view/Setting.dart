
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  RaisedButton(
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
                    child:Text('Sign out'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
