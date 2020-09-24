import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('စကားဝိုင်း'),
          backgroundColor: Constants.primaryColor,
        ),
        body: Container(

        ),
      ),
    );
  }
}
