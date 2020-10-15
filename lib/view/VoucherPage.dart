import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/Voucher/VoucherOrder.dart';
import 'package:uni_pharmacy/view/Widget/TitleTextColor.dart';
import 'package:uni_pharmacy/view/Widget/VoucherCard.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  bool loading;
  String userName;
  int current = 0;
  List<String> imgList = [];
  int prepareOrderCount,deliverOrderCount;

  fetchData() async {
      loading = true;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString("user_name");
    });
    FirebaseFirestore.instance.collection("voucher").where('status',isEqualTo: Constants.orderPrepare).get().then((value){
      setState(() {
        prepareOrderCount = value.docs.length;
      });
      print('number of prepare order'+prepareOrderCount.toString());
    });

    FirebaseFirestore.instance.collection("voucher").where('status',isEqualTo: Constants.orderDeliver).get().then((value){
      setState(() {
        deliverOrderCount = value.docs.length;
      });
      print('number of deliver order'+deliverOrderCount.toString());
    });
    setState(() {
      loading=false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///Declaration
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: Text('ဘောက်ချာ'),backgroundColor: Constants.primaryColor,),
        body: SafeArea(
          child: loading==true? Container(height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()),): SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  deliverOrderCount ==0 || deliverOrderCount==null ? SizedBox(height: 20.0,): Container(
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width:75,
                            child: Text('ရက်စွဲ',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont),)),
                        Text('ဘောက်ချာအမှတ်',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont),),
                        Container(
                          width: 120,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),
                  ),
                  deliverOrderCount==0 || deliverOrderCount==null ? SizedBox(height: 10.0,): StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('voucher').where("status",isEqualTo: Constants.orderDeliver).orderBy('date_time').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if(snapshot.hasData){
                          return ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data.documents.map((DocumentSnapshot document) {
                              return InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VoucherOrder(document.data()['voucher_id'],document.data()['voucher_number'])),
                                    );
                                  },
                                  child: VoucherCard(document.data()['date_time'], document.data()['voucher_number'], document.data()['status']));
                            }).toList(),
                          );
                        }else{
                          return TitleTextColor("No data", Constants.thirdColor);
                        }
                      }),
                  deliverOrderCount==0 || deliverOrderCount==null ? Center(child: SizedBox(child: Text('ဘောက်ချာ မရှိသေးပါ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16),),)):SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
