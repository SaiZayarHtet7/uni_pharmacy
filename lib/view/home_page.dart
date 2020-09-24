import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/ChatBox.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uni_pharmacy/view/OrderPage.dart';
import 'package:uni_pharmacy/view/Setting.dart';
import 'package:uni_pharmacy/view/VoucherPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    DashBoard(),
    ChatBox(),
    VoucherPage(),
    OrderPage(),
    SettingPage(),

  ];
  int languageKey;
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
