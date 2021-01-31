import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/providers/Connectivity.dart';
import 'package:uni_pharmacy/service/auth_service.dart' as auth;
import 'package:uni_pharmacy/testing/product.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin{

  final email_controller= TextEditingController();
  final password_controller= TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool pass_visibility,showLoading;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;

  @override
  void initState() {
    // TODO: implement initState
    Firebase.initializeApp();
    pass_visibility=true;
    showLoading=false;

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true,));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        fcmToken=token.toString();
      });
    });
    super.initState();
  }



  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validatePassword(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 8)
      return 'invalid Password';
    else
      return null;
  }
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      setState(() {
        showLoading=true;
      });
      _formKey.currentState.save();
    }
  }
  @override
  Widget build(BuildContext context) {
    return DoubleBack(
        message:"Press back again to close",
      child: MultiProvider(
        providers: [
          Provider<NetworkProvider>(
            create: (context) => NetworkProvider(),
            dispose: (context, service) => service.disposeStreams(),
          )
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
            body: SafeArea(

              child: Center(
                child: Consumer<NetworkProvider>(
                  builder: (context,networkProvider,child){
                    return StreamProvider<ConnectivityResult>.value(value: networkProvider.networkStatusController.stream,
                    child: Consumer<ConnectivityResult>(
                      builder: (context,value,_){
                        if(value==null) {
                          return Container(
                            width: double.infinity, height: double.infinity,
                            child: Center(
                              child: Text('Error in Connectivity result'),),);
                        }
                        return value==ConnectivityResult.none ? Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: Image.asset('assets/image/logo.jpg',width: MediaQuery.of(context).size.width/2,)),
                              Lottie.asset('assets/anim/offline_anim.json',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text('Please connect Mobile Internet or Wifi\n to use Application',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                              SizedBox(height: 60.0,),
                            ],

                          ),
                        ): Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(20.0),
                            child:SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(child: Image.asset('assets/image/logo.jpg',width: MediaQuery.of(context).size.width/2,)),
                                  SizedBox(height: 20.0,),
                                  Container(width: double.infinity,
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text('Login to your account',style: TextStyle(fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold,fontSize: 19.0),),),
                                  SizedBox(height: 10.0,),
                                  Container(
                                    padding: EdgeInsets.only(top: 5,bottom: 10),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          ///Email Field
                                          TextFormField(
                                            controller: email_controller,
                                            validator: validateEmail,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontFamily: Constants.PrimaryFont
                                            ),
                                            decoration: InputDecoration(
                                                labelText: 'E-mail',
                                                labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                                                hintText: 'username@gmail.com',
                                                prefixIcon: Icon(Icons.mail,color: Constants.primaryColor,),
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
                                          ///Password Field
                                          TextFormField(
                                            controller: password_controller,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontFamily: Constants.PrimaryFont
                                            ),
                                            keyboardType: TextInputType.emailAddress,
                                            obscureText: pass_visibility,
                                            validator: validatePassword,
                                            decoration: InputDecoration(
                                              hintText: '********',
                                                labelText: 'Password',
                                                labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),
                                                prefixIcon: Icon(Icons.vpn_key,color: Constants.primaryColor,),
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.0,),
                                  if (showLoading==true) CircularProgressIndicator() else Container(
                                    height: 50.0,
                                    child: RaisedButton(

                                      onPressed: () async {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        SharedPreferences pref=await SharedPreferences.getInstance();
                                        _validateInputs();
                                        if(email_controller.text!=null || password_controller.text!=null) {

                                          FirebaseAuth _auth=FirebaseAuth.instance;
                                          try {
                                                UserCredential response = await _auth.signInWithEmailAndPassword(
                                                email: email_controller.text, password: password_controller.text);
                                                        String userID= response.user.uid;
                                                        print("userID $userID");
                                                FirebaseFirestore db=FirebaseFirestore.instance;
                                                String isAdmin;
                                                db.collection("user").doc(userID).get().then((value) {
                                                  isAdmin = value.data()['is_admin'].toString();
                                                  print("isAdmin $isAdmin");

                                                  if(isAdmin=="true"){
                                                    setState(() {
                                                      showLoading=false;
                                                      pref.setString('user_name', email_controller.text);
                                                    });

                                                    CollectionReference users = FirebaseFirestore.instance.collection('user');
                                                    users
                                                        .doc(userID)
                                                        .update({'token': fcmToken})
                                                        .then((value) {
                                                      print("User Updated");
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => DashBoard()),
                                                      );
                                                    })
                                                        .catchError((error) { setState(() {
                                                      showLoading=false;
                                                    });
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                      content: Text('နောက်တကြိမ် ပြန်လည် ကြိူးစားကြည့်ပါ fcm'),
                                                      duration: Duration(seconds: 3),
                                                      backgroundColor: Constants.emergencyColor,
                                                    ));
                                                    }
                                                    );
                                                  }else{
                                                    setState(() {
                                                      showLoading=false;
                                                    });
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                      content: Text('သင်သည် admin မဖြစ်သဖြင့် login ဝင်မရနိုင်ပါ'),
                                                      duration: Duration(seconds: 3),
                                                      backgroundColor: Constants.emergencyColor,
                                                    ));
                                                  }
                                                });

                                              }  on FirebaseAuthException catch(e){
                                                        if (e.code == 'user-not-found') {
                                                          setState(() {
                                                            showLoading=false;
                                                          });
                                                          _scaffoldKey.currentState
                                                              .showSnackBar(SnackBar(
                                                            content: Text('Register မလုပ်ရသေးပါ'),
                                                            duration: Duration(seconds: 3),
                                                            backgroundColor: Constants.emergencyColor,
                                                          ));
                                                          setState(() {
                                                            showLoading=false;
                                                          });
                                                        } else if (e.code == 'wrong-password') {
                                                          _scaffoldKey.currentState
                                                              .showSnackBar(SnackBar(
                                                            content: Text('password မှားနေပါသည်'),
                                                            duration: Duration(seconds: 3),
                                                            backgroundColor: Constants.emergencyColor,
                                                          ));
                                                          setState(() {
                                                            showLoading=false;
                                                          });
                                                        }
                                              } catch (e) {
                                                                print(e);
                                                                setState(() {
                                                                  showLoading=false;
                                                                });
                                                          }
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
                                          child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  SizedBox(
                                    height: 130.0,
                                  ),
                                  Text(
                                    'Version 1.1.1',
                                    style:
                                    TextStyle(color: Constants.primaryColor, fontSize: 20),
                                  ),
                                ],
                              ),
                            )
                        );

                      },
                    ),);
                  }

                ),
              ),
            ),
        ),
      ),
    );
  }
}
