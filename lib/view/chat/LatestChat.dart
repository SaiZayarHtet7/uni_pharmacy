import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';

Widget LatestChat(String userId,String sender){
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('user').doc('$userId').collection('chat').orderBy('created_date',descending:true).limit(1).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading");
      }

      return Container(
        height: 25,
        child: new ListView(
          physics:const NeverScrollableScrollPhysics(),
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                document.data()['sender']=="admin"? Text('you:  ',style: TextStyle(fontFamily: Constants.PrimaryFont),):SizedBox(),
                document.data()['message_type']=="image"?  Text('sent a photo',style: TextStyle(fontFamily: Constants.PrimaryFont)):Text(document.data()['message_text'],style: TextStyle(fontFamily: Constants.PrimaryFont)),
              ],
            );
          }).toList(),
        ),
      );
    },
  );
}