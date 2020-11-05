import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:intl/intl.dart';

class NotiPage extends StatefulWidget {
  @override
  _NotiPageState createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  var format =new DateFormat('dd-MM-yyyy hh:mm a');
  int secondInDate=86400000;
  int yesterday;
  String convertVoucher(String vNo){
    do{
      vNo="0"+vNo;
    }while(vNo.length<5);
    return  vNo;
  }

  @override
  void initState() {
    // TODO: implement initState
    
    fetchData();
    super.initState();
  }

  fetchData() async{
    setState(() {
      yesterday=DateTime.now().millisecondsSinceEpoch-secondInDate;
    });
  }
  
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon:Icon( Icons.arrow_back_ios_rounded),
            onPressed: ()=>Navigator.of(context).pop()
        ),
        toolbarHeight: 70,
        title: Text('Notification'),
      ),
      body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('noti').orderBy('created_date',descending: true).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return Container(
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data.docs.map((DocumentSnapshot document)
                    {
                      // return PriceCard(document.data()['price_kind'], document.data()['quantity'], document.data()['unit'], document.data()['price']);
                      return Column(
                        children: [
                          ListTile(
                            leading:document.data()['photo']==""? Container(width: 50,height: 50,
                                child: Icon(Icons.account_circle,color: Constants.thirdColor,size: 50,)): CachedNetworkImage(
                              imageUrl:document.data()['photo'],
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => Container(
                                width:50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Constants.thirdColor,width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                            title: Text(document.data()['noti_title'],style: TextStyle(fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5,),
                                Text(document.data()['noti_text'],style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Text(format.format(DateTime.fromMicrosecondsSinceEpoch(int.parse(document.data()['created_date'].toString())*1000)).toString(),
                                      style: TextStyle(fontFamily: Constants.PrimaryFont,),),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:8.0),
                            child: Divider(thickness: 1.2,color: Constants.secondaryColor,),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
      ),
    );
  }
}
