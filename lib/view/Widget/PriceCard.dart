import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy/util/constants.dart';

Widget PriceCard(String kind,String quantity,String unit,String price){

  return Card(
    elevation: 3,
    child: Container(
      height: 105.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 5.0),
      child: Column(
        children: [
          Container(width: double.infinity,
              child: Text(kind,style: TextStyle(color: Constants.primaryColor,fontSize: 16.0,fontFamily: Constants.PrimaryFont),)),
          SizedBox(height: 4.0,),
          Divider(thickness: 1,color: Colors.grey,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(quantity,style: TextStyle(color: Constants.thirdColor,fontSize: 16.0,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5.0,),
                  Text(unit,style: TextStyle(fontSize: 16.0,fontFamily: Constants.PrimaryFont),)
                ],
              ),
              SizedBox(width: 10.0,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Constants().oCcy.format(int.parse(price)) ,style: TextStyle(color: Constants.thirdColor,fontSize: 16.0,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5.0,),
                  Text("ကျပ်",style: TextStyle(fontSize: 16.0,fontFamily: Constants.PrimaryFont),)
                ],
              ),
            ],
          )
        ],
      ),
    ),
  );
}