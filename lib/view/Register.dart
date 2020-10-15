import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:uni_pharmacy/models/user_model.dart';
import 'package:uni_pharmacy/service/auth_service.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uni_pharmacy/util/constants.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String searchName;
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
        title: Text('Account list'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child:TextFormField(
              style: TextStyle(
                  fontSize: 17.0,
                  fontFamily: Constants.PrimaryFont
              ),
              onChanged: (value){
                setState(() {
                  searchName=value.toString();
                });
              },
              decoration: InputDecoration(
                  hintText: '',
                  prefixIcon: Icon(Icons.search,color: Constants.primaryColor,),
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
          ),
          Container(
            margin: EdgeInsets.only(top: 70),
            child: StreamBuilder<QuerySnapshot>(
                stream:(searchName==""||searchName==null)?
                FirestoreService().get('user'):
                          FirebaseFirestore.instance
                            .collection('user').where("search_name", arrayContains: searchName).snapshots(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasError){
                    return Text('Something went wrong in slide');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,));
                  }
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView(
                      children: snapshot.data.documents.map((DocumentSnapshot document)
                      {
                        return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: Colors.white,
                              elevation:5,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditRegister(document.data()['user_name'],document.data()['phone_number'],document.data()['address'],document.data()['email']))
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10.0,),
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1,color: Constants.thirdColor
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: document.data()['profile_image']==""? Icon(Icons.account_circle,color: Constants.thirdColor,size: 50,):
                                        CachedNetworkImage(
                                          imageUrl:document.data()['profile_image'],
                                          fit: BoxFit.cover,
                                          imageBuilder: (context, imageProvider) => Container(
                                            width: 100.0,
                                            height: 100.0,
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                  child: Text('အမည်',style: TextStyle(color: Constants.primaryColor,fontWeight: FontWeight.w500,fontFamily: Constants.PrimaryFont),)),
                                              SizedBox(width: 5.0,),
                                              Text(document.data()['user_name'],style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: Constants.PrimaryFont
                                              ),),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(width: 70,
                                                  child: Text('ဖုန်းနံပါတ်',style: TextStyle(color: Constants.primaryColor,fontWeight: FontWeight.w500,fontFamily: Constants.PrimaryFont),)),
                                              SizedBox(width: 5.0,),
                                              Text(document.data()['phone_number'],style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: Constants.PrimaryFont
                                              ),),
                                            ],
                                          )
                                        ],
                                      )

                                    ],
                                  )
                                ),
                              ),
                        );
                      }).toList(),
                    ),
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditRegister("","","",""))
          );
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Constants.primaryColor,
      ),
    );
  }
}

class EditRegister extends StatefulWidget {
  final String userName,phoneNumber,address,email;

  const EditRegister(this.userName, this.phoneNumber, this.address, this.email);
  @override
  _EditRegisterState createState() => _EditRegisterState(userName,phoneNumber,address,email);
}

class _EditRegisterState extends State<EditRegister> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController=TextEditingController();
  final emailController =TextEditingController();
  final passwordController=TextEditingController();
  final confirmPasswordController=TextEditingController();
  final addressController=TextEditingController();
  final phoneController=TextEditingController();
  bool loading;
  String userName="",phoneNumber="",address="",email="";
  bool pass_visibility,conpass_visibility,readOnly;

  _EditRegisterState(this.userName, this.phoneNumber, this.address, this.email);

  @override
  void initState() {
    // TODO: implement initState
    if(userName!=""){
      nameController.text=userName;
      phoneController.text=phoneNumber;
      addressController.text=address;
      emailController.text=email;
      readOnly=true;
    }else{
      readOnly=false;
    }
    loading=false;
    pass_visibility=true;
    conpass_visibility=true;
    super.initState();
  }


  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == "")
      return 'မှန်ကန်သော အီးမေးကို ထည့်ပါ';
    else
      return null;
  }

  String validatePassword(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 8)
      return 'စကားဝှက် အားနဲနေသည် အနဲဆုံး ၈ လုံးထည့်ပေးပါ';
    else
      return null;
  }
  String validateConfirmPassword(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 8 )
      return 'စကားဝှက် အားနဲနေသည် အနဲဆုံး ၈ လုံးထည့်ပေးပါ';
    if ( value != passwordController.text)
      return 'စကားဝှက် မတူညီပါ';
    else
      return null;
  }
  String validateAddress(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 15 || value=="")
      return 'နေရပ်လိပ်စာအမှန် ထည့်ပါ';
    else
      return null;
  }

  String validateName(String value) {
// Indian Mobile number are of 10 digit only
    if (value =="")
      return 'အမည် ထည့်ပါ';
    else
      return null;
  }
    String validatePhone(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length< 9)
      return 'ဖုန်းနံပါတ်အမှန် ထည့်ပါ';
    else
      return null;
  }
  
  ///for searching filter
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        title: Text('Registration'),
        backgroundColor: Constants.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 10.0,),
                      TextFormField(
                        readOnly: readOnly,
                        controller: nameController,
                        validator: validateName,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'အမည်',
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.account_circle,color: Constants.primaryColor,),
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
                      TextFormField(
                        readOnly: readOnly,
                        controller: phoneController ,
                        keyboardType: TextInputType.phone,

                        validator: validatePhone,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'ဖုန်းနံပါတ်',
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.phone,color: Constants.primaryColor,),
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
                      TextFormField(
                        readOnly: readOnly,
                        controller: addressController ,
                        validator: validateAddress,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'လိပ်စာ',
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.location_on,color: Constants.primaryColor,),
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
                      TextFormField(
                        readOnly: readOnly,
                        controller: emailController ,
                        validator: validateEmail,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'အီး-မေးလ် လိပ်စာ',
                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.mail_outline,color: Constants.primaryColor,),
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
                      readOnly==true?SizedBox(): TextFormField(
                        controller: passwordController ,
                        validator: validatePassword,
                        obscureText: pass_visibility,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'စကားဝှက်',

                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.lock,color: Constants.primaryColor,),
                            suffixIcon: IconButton(icon: Icon(pass_visibility==true? Icons.visibility : Icons.visibility_off,color: Constants.primaryColor,),onPressed: (){
                              setState(() {
                                if(pass_visibility==true) { pass_visibility=false; }
                                else { pass_visibility= true; }
                              });
                            },),
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
                      readOnly==true?SizedBox():SizedBox(height: 10.0,),
                      readOnly==true?SizedBox(): TextFormField(
                        controller: confirmPasswordController ,
                        validator: validateConfirmPassword,
                        obscureText: conpass_visibility,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontFamily: Constants.PrimaryFont
                        ),
                        decoration: InputDecoration(
                            labelText: 'အတည်ပြု စကားဝှက်',

                            labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                            hintText: '',
                            prefixIcon: Icon(Icons.lock,color: Constants.primaryColor,),
                            suffixIcon: IconButton(icon: Icon(conpass_visibility==true? Icons.visibility : Icons.visibility_off,color: Constants.primaryColor,),onPressed: (){
                              setState(() {
                                if(conpass_visibility==true) { conpass_visibility=false; }
                                else { conpass_visibility= true; }
                              });
                            },),
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
                      readOnly==true?SizedBox():SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: 50.0,
                            width: 150.0,
                            child: RaisedButton(
                              color: Colors.white,
                              elevation: 0,
                              child: Text('Cancel',style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  side: BorderSide(color: Constants.primaryColor)
                              ), onPressed: () async {
                                Navigator.pop(context);
                            },
                            ),
                          ),
                          readOnly==true?SizedBox():SizedBox(width: 10.0,),
                          readOnly==true?SizedBox():Container(
                            height: 50.0,
                            width: 150,
                            child: RaisedButton(
                              onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(()  {
                                      loading=true;
                                    });
                                    ///Registering Firebase Auth
                                      FirebaseAuth _auth=FirebaseAuth.instance;
                                    try {
                                      UserCredential response = await _auth.createUserWithEmailAndPassword(
                                          email: emailController.text, password: passwordController.text);
                                      print(response.additionalUserInfo);
                                      print(response.toString());
                                      String uid=response.user.uid.toString();
                                      
                                      ///User info saving in firebase
                                      
                                      UserModel model =UserModel(
                                        uid: uid,
                                        phoneNumber: phoneController.text,
                                        address: addressController.text,
                                        email: emailController.text,
                                        isAdmin: false,
                                        password: passwordController.text,
                                        profileImage:"",
                                        token: "",
                                        userName: nameController.text,
                                        searchName: setSearchParam(nameController.text)
                                      );
                                      print('$model');
                                      
                                      FirestoreService().registerUser('user', model);
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text('အောင်မြင်ပါသည်'),
                                        duration: Duration(seconds: 3),
                                        backgroundColor:Colors.greenAccent,
                                      ));
                                      Navigator.pop(context);
                                      // response.user.uid
                                    } on FirebaseAuthException catch (e) {
                                      if(e.code == 'weak-password'){
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text("Password အားနဲနေသည်"),
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Constants.emergencyColor,
                                        ));
                                      }else if(e.code=='email-already-in-use'){
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text("Email မှာအသုံးပြုပြီးသား ဖြစ်နေသည်"),
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Constants.emergencyColor,
                                        ));

                                      }
                                    } catch (e){
                                      print("error$e");
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text(e.toString()),
                                        duration: Duration(seconds: 3),
                                        backgroundColor: Constants.emergencyColor,
                                      ));
                                    }

                                    setState(() {
                                      loading=false;
                                    });
                                    
                                  }
                                
                                

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
                                  child: Text('Register',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              loading == true?
                  Container(
                    padding: EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height/1.2,
                    width: MediaQuery.of(context).size.width,
                      child: Center(child: Container(
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.transparent),
                              color: Colors.blueGrey[100]),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)))):SizedBox(height: 1,)
            ],
          ),
        ),
      ),
    );
  }
}
