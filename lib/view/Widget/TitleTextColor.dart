import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';

Widget TitleTextColor(String text,Color color){
  return Text("$text",style:TextStyle(color: color,fontFamily: Constants.PrimaryFont,fontSize: 18) ,);
}