import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uuid/uuid.dart';

class EditUnt extends StatefulWidget {
  @override
  _EditUntState createState() => _EditUntState();
}

class _EditUntState extends State<EditUnt> {
  final unitController=TextEditingController();
  var uuid=Uuid();

  @override
  void initState() {
    // TODO: implement initState
    Firebase.initializeApp();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        backgroundColor: Constants.primaryColor, title: Text('ယူနစ် အသစ်ထည့်ရန် ',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont),),),
      body:Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().get('unit'),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasError){
            return Text('Something went wrong in unit');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,));
          }
          return Container(
            child: ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document)
              {
                return Column(
                  children: [
                  ListTile(
                    onTap: (){
                      unitController.text= document.data()['unit'];
                      showAddBottomsheet(context,document.data()['id']);
                    },
                    title:Text( document.data()['unit'],),),
                    Divider(color: Colors.black45,thickness: 2,)
                  ],

                );
                // return ListTile(
                //   onTap: (){
                //     unitController.text= document.data()['unit'];
                //     showAddBottomsheet(context,document.data()['id']);
                //   },
                //   title:Text( document.data()['unit'],),
                // );
              }).toList(),
            ),
          );
        }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showAddBottomsheet(context,'');
          unitController.text="";
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Constants.primaryColor,
      ),
    );
  }
  showAddBottomsheet(BuildContext context,String document){
    showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: unitController,
                      style: TextStyle(
                          fontSize: 17.0,
                          fontFamily: Constants.PrimaryFont
                      ),
                      decoration: InputDecoration(
                          labelText: 'Unit Name',
                          labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                          hintText: 'Eg.ခု,ကတ်',
                          enabledBorder: new OutlineInputBorder(
                            borderSide:new BorderSide(color: Constants.primaryColor),
                          ),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Constants.primaryColor)
                          ),
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Constants.primaryColor),
                          )
                      ) ,
                    ),
                    SizedBox(height: 10.0,),
                    RaisedButton(
                      onPressed: () async {
                        if(document==""){
                          FirestoreService().add('unit',unitController.text.toString(),uuid.v4());
                        }else {
                          FirestoreService().update('unit', unitController.text.toString(), document);
                        }
                        Navigator.pop(context);
                        setState(() {
                          unitController.text="";
                        });
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Hexcolor('#fd9346'),Constants.primaryColor,Hexcolor('#fd9346'),],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text( document==""?'ထည့်သွင်းမည်':"ပြင်ဆင်မည်",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    RaisedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        setState(() {
                          unitController.text="";
                        });
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text('ပယ်ဖျက်မည်', style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),
                          ),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: Constants.primaryColor,
                          width: 1,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.circular(80)),
                    ),

                    // ListTile(
                    //   leading: Icon(Icons.cancel),
                    //   title: Text('ပယ်ဖျက်ပါ'),
                    //   onTap: () => Navigator.pop(context),
                    // )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
