
import 'package:flutter/material.dart';

class GetandSet with ChangeNotifier{
 String _url = "";

  get url => _url;

 changeName(String value) {
   _url = value;
   notifyListeners();
 }

}