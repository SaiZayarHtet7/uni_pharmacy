import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: Text('ဘောက်ချာ'),backgroundColor: Constants.primaryColor,),
        body: SafeArea(
          child: Container(
          ),
        ),
      ),
    );
  }
}
