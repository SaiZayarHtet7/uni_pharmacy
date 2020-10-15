


import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as httpLib;
class NotiService{
  List<String> tokenList=List();
  String adminToken;
Future<void> sendNoti(String title,String body,String token) async {
  final response = await httpLib
      .post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        "Accept": "application/json",
        'Content-type': 'application/json',
        'Authorization': 'key=AAAA_TFyCCI:APA91bFRjYi7VAeWA2FX3QSXnVpc6qse3CDan4oy3rQMe-NedbEa7J5Tm3QePc4M5tYxQ6gVOMAiZ9GAwnukE4Ub8OBHQ3D57i668NaDpBzFLpB7T0z1aBBfuexTrebYNwHho1Q9KvtM'
      },
      body: json.encode({
        'notification':{
          "body": "$body",
          "title": "$title",
          "sound": 'default',
          "android_channel_id": "id",
          "image": "https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/viber_image_2020-09-12_17-23-52.jpg?alt=media&token=b7f5a606-9063-4401-9946-d5a0aeb62302"
        },
        "priority": "high",
        "collapse_key" : "type_a",
        "data": {
          "clickaction": "FLUTTERNOTIFICATIONCLICK",
          "id": "1",
          "status": "done"
        },
        "to": "$token"
      }))
      .catchError((onError) {
    print(onError);
    throw Exception('Failed to load ');

  });
}
}