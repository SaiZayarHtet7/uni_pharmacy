import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uni_pharmacy/models/MessageModel.dart';
import 'package:uni_pharmacy/service/ChatService.dart';
import 'package:uni_pharmacy/service/NotiService.dart';
import 'package:uni_pharmacy/service/firebase_storage.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ChatDetail extends StatefulWidget {
  final String userName,userId,userPhoto;
  const ChatDetail( this.userName, this.userId, this.userPhoto);

  @override
  _ChatDetailState createState() => _ChatDetailState(userName,userId,userPhoto);
}


class _ChatDetailState extends State<ChatDetail> {
  String userName,userId,userPhoto;
  var format =new DateFormat('dd-MM-yyyy hh:mm a');
  _ChatDetailState(this.userName, this.userId,this.userPhoto);
  final messageController = TextEditingController();
  var uuid=Uuid();
  final picker = ImagePicker();
  String msg;
  String token;
  File messageImage;



  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }


  fetchData() async{
    FirebaseFirestore.instance.collection("user").doc('$userId').get().then((value){
      setState(() {
        token= value.data()['token'];
        print(token);
      });
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        iconTheme: new IconThemeData(color: Constants.primaryColor),
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: (){
                  Navigator.pop(context);
                }
            ),
            SizedBox(width: 10,),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1,color: Constants.thirdColor
                ),
                shape: BoxShape.circle,
              ),
              child: userPhoto==""? Container(width: 50,height: 50,
                  child: Icon(Icons.account_circle,color: Constants.thirdColor,size: 45,)):
              CachedNetworkImage(
                imageUrl:userPhoto,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  width:50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(width: 10.0,),
            Text('$userName',style: TextStyle(color: Constants.primaryColor),),
          ],
        ),
        backgroundColor: Colors.white,),
      body:Stack(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 60),
            child: StreamBuilder<QuerySnapshot>(
              stream:FirebaseFirestore.instance.collection('user').doc('$userId').collection('chat').orderBy('created_date',descending: true).limit(300).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Container(child: CircularProgressIndicator(),));
                }
                return ListView(
                  reverse: true,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    bool showDate;
                    return Align(
                      alignment:document.data()['sender']=="admin" ?Alignment.centerRight :Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:document.data()['sender']=="admin"?CrossAxisAlignment.end: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 10.0,),
                              document.data()['sender']=="admin" ?SizedBox():
                              userPhoto=="" || userPhoto==null ? Container(width: 35,height: 35,
                                  child: Icon(Icons.account_circle,color: Constants.thirdColor,size: 40,)):
                              CachedNetworkImage(
                                imageUrl:userPhoto,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) => Container(
                                  width:35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              GestureDetector(
                                onTap: (){
                                  print("hello");
                                  setState(() {
                                    if(showDate==false){
                                      showDate=true;
                                    }else{
                                      showDate=false;
                                    }
                                  });
                                  print(showDate);
                                },
                                onLongPress: (){
                                  print('long');
                                  if(document.data()['sender'] == "admin") {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            title: Text(
                                                'ပို့ထားသောစာကို ဖျက်မည်လား?',
                                                style: new TextStyle(
                                                    fontSize: 20.0,
                                                    color: Constants
                                                        .thirdColor,
                                                    fontFamily: Constants
                                                        .PrimaryFont)),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('ဖျက်မည်',
                                                    style: new TextStyle(
                                                        fontSize: 16.0,
                                                        color: Constants
                                                            .primaryColor,
                                                        fontFamily: Constants
                                                            .PrimaryFont
                                                    ),
                                                    textAlign: TextAlign
                                                        .right),
                                                onPressed: () async {
                                                  ChatService().deleteMessage(userId, document.data()['message_id']);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('မဖျက်ပါ',
                                                    style: new TextStyle(
                                                        fontSize: 16.0,
                                                        color: Constants
                                                            .primaryColor,
                                                        fontFamily: Constants
                                                            .PrimaryFont
                                                    ),
                                                    textAlign: TextAlign
                                                        .right),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          ),
                                    );
                                  }else{
                                  }
                                },
                                child: document.data()['message_type']=="image"?
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LargeImage(document.data()['message_text'])),
                                    );
                                  },
                                  child: Container(
                                    width:  MediaQuery.of(context).size.width/1.4,
                                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(color:document.data()['sender']=="admin" ? Constants.thirdColor:Colors.grey[300],
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10),bottomLeft: Radius.circular(document.data()['sender']=="admin" ?10:0),bottomRight: Radius.circular(document.data()['sender']=="admin" ?0:10))),
                                    child: Column(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:document.data()['message_text'],
                                          fit: BoxFit.fitWidth,
                                          placeholder: (context, url) => CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ],
                                    ),
                                  ),
                                ): Container(
                                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width/1.4),
                                    decoration: BoxDecoration(color:document.data()['sender']=="admin" ? Constants.thirdColor:Colors.grey[300],
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10),bottomLeft: Radius.circular(document.data()['sender']=="admin" ?10:0),bottomRight: Radius.circular(document.data()['sender']=="admin" ?0:10))),
                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                    child: Text(document.data()['message_text'],style: TextStyle(color:document.data()['sender']=="admin" ? Colors.white :Colors.black,fontSize: 16),)
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            margin:document.data()['sender']=="admin"? EdgeInsets.symmetric(horizontal: 10.0):EdgeInsets.only(left: 50),
                            child: Text(format.format(DateTime.fromMicrosecondsSinceEpoch(int.parse(document.data()['created_date'].toString())*1000)).toString(),
                            style: TextStyle(color: Colors.grey,fontSize:13),),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:  Container(
              height: 50.0,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(icon: Icon(Icons.camera_alt), onPressed: (){
                        _openCamera(context);
                      }),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(icon: Icon(Icons.photo), onPressed: (){
                        _openGallary(context);
                      }),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(0),
                        height: 50,
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          onChanged: (v){

                          },
                          style: TextStyle(
                              fontSize: 15.0, fontFamily: Constants.PrimaryFont),
                          controller: messageController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              hintText: 'စာတို',
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: new BorderSide(color: Colors.black,width: 1),
                              ),
                              focusedBorder: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: new BorderSide(color: Colors.black,width: 1),),
                              border: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: new BorderSide(color: Colors.black,width: 1),
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(icon: Icon(Icons.send,color: Constants.primaryColor,), onPressed: (){
                        if(messageController.text==null || messageController.text==""){
                          ///Nothing work
                        }else{
                          int dateTime= DateTime.now().millisecondsSinceEpoch;
                          FirebaseFirestore.instance.collection('user').doc(userId)
                              .update({'final_chat_date_time': dateTime,
                                        'is_new_chat':"old",
                                        })
                              .then((value) => print("status of User Updated"))
                              .catchError((error) => print("Failed to update user: $error"));

                          ///add noti of message to the user account

                          FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
                            int notiCount=int.parse(document.data()['message_noti'].toString());
                            print("notiCOunt"+notiCount.toString());
                            FirebaseFirestore.instance.collection('user').doc(userId)
                                .update({'message_noti': ++notiCount})
                                .then((value) => print("message noti  User Updated"))
                                .catchError((error) => print("Failed to update user: $error"));
                          });

                         MessageModel messageModel= MessageModel(
                           messageId: uuid.v4(),
                           sender: "admin",
                           msgText: messageController.text,
                           msgType: "text",
                           createdDate:dateTime
                         );
                         ChatService().sendMessage(userId, messageModel);
                         print(token);
                         NotiService().sendNoti("Sun Pharmacy send a message",messageController.text, token);
                           messageController.text="";
                          FirebaseFirestore.instance.collection('user').doc(userId)
                              .update({'status': 'read'})
                              .then((value) => print("User Updated"))
                              .catchError((error) => print("Failed to update user: $error"));
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ) ,
    );
  }

  Future _openGallary(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    File tmpFile = File(picture.path);
    messageImage= tmpFile;
    String imageLink=await FirebaseStorageService().UploadPhoto('chat', messageImage);
    MessageModel messageModel= MessageModel(
        messageId: uuid.v4(),
        sender: "admin",
        msgText: imageLink,
        msgType: "image",
        createdDate:DateTime.now().millisecondsSinceEpoch
    );

    ChatService().sendMessage(userId, messageModel);
    NotiService().sendNoti("Sun Pharmacy", "send a photo", token);
    FirebaseFirestore.instance.collection('user').doc(userId)
        .update({'status': 'read'})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future _openCamera(BuildContext context) async {
    final picture = await picker.getImage(source: ImageSource.camera);
    File tmpFile = File(picture.path);
    messageImage= tmpFile;
    String imageLink=await FirebaseStorageService().UploadPhoto('chat', messageImage);
    MessageModel messageModel= MessageModel(
        messageId: uuid.v4(),
        sender: "admin",
        msgText: imageLink,
        msgType: "image",
        createdDate:DateTime.now().millisecondsSinceEpoch
    );
    ChatService().sendMessage(userId, messageModel);
    NotiService().sendNoti("Sun Pharmacy", "send a photo", token);
    FirebaseFirestore.instance.collection('user').doc(userId)
        .update({'status': 'read'})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

}

class LargeImage extends StatelessWidget {
  String imgUrl;
  LargeImage(this.imgUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child:InkWell(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),),
    );
  }
}
