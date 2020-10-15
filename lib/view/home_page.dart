import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/ChatBox.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uni_pharmacy/view/OrderPage.dart';
import 'package:uni_pharmacy/view/Setting.dart';
import 'package:uni_pharmacy/view/VoucherPage.dart';

class HomePage extends StatefulWidget {
 final int index;

  const HomePage( this.index);

  @override
  _HomePageState createState() => _HomePageState(this.index);
}

class _HomePageState extends State<HomePage> {
  int index;
  _HomePageState(this.index);

  Future<bool> _onWillPop() async {
        print('hellp');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text( 'Application မှထွက်ရန် သေချာပြီလား?',
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
                  SystemNavigator.pop();
                },
              ),
              FlatButton(
                child: Text('Cancel',
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
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: WillPopScope(
        onWillPop: _onWillPop,
          child: MyBottomNavigationBar( index)),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  final int _currentIndex;

  const MyBottomNavigationBar( this._currentIndex);
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState(this._currentIndex);
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex;
  final List<Widget> _children = [
    DashBoard(),
    ChatBox(),
    VoucherPage(),
    OrderPage(),
    SettingPage(),
  ];
  int languageKey;

  _MyBottomNavigationBarState(this._currentIndex);
  // ignore: must_call_super
  void initState(){
    fetchUpdatedData();
  }

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          unselectedItemTextStyle: TextStyle(fontSize: 10.0),
          selectedItemTextStyle: TextStyle(fontSize: 12.0),
          selectedItemBackgroundColor: Constants.primaryColor,
          selectedItemBorderColor: Colors.white,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: _currentIndex,
        onSelectTab: onTappedBar,
        items: [
          FFNavigationBarItem(
            iconData: Icons.home,
            label: languageKey == 1 ? 'Home' : 'ပင်မစာမျက်နှာ',
          ),
          FFNavigationBarItem(
            iconData: Icons.message,
            label: languageKey == 1 ? 'ChatBox' : 'စကားဝိုင်း',
          ),
          FFNavigationBarItem(
            iconData: Icons.playlist_add_check,
            label: languageKey == 1 ? 'Voucher' : 'ဘောက်ချာ',
          ),
          FFNavigationBarItem(
            iconData: Icons.assignment,
            label: languageKey == 1 ? 'Order List' : 'အော်ဒါများ',
          ),
          FFNavigationBarItem(
            iconData: Icons.settings,
            label: languageKey == 1 ? 'Setting' : 'ပြင်ဆင်ရန်',
          ),

        ],
      ),
    );
  }

  void fetchUpdatedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      languageKey = preferences.getInt('LanguageKey');
    }
    );
  }
}
