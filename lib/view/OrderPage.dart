import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';
class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: Text('အော်ဒါများ'),backgroundColor: Constants.primaryColor,),
        body: SafeArea(
          child: Container(

          ),
        ),
      ),
    );
  }
}
