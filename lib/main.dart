import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splash/flutter_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy/testing/product.dart';
import 'package:uni_pharmacy/util/constants.dart';
import 'package:uni_pharmacy/view/DashBoard.dart';
import 'package:uni_pharmacy/view/LoginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences preferences=await SharedPreferences.getInstance();
  String userName=preferences.getString('user_name');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(home:
  Splash(
    seconds: 3,
    navigateAfterSeconds: userName == null ? LoginPage() : DashBoard(),
    image: Image.asset('assets/image/logoCircle.png',),

    backgroundColor:Constants.primaryColor,
    title: Text('UNI Pharmacy application မှ ကြိုဆိုပါသည်',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont),),
    photoSize: 100,
    loaderColor: Colors.white ,
  ),));
}
//
// class MyApp extends StatelessWidget {
//
//   final  Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initialization,
//       builder: (context,snapshot){
//
//         if(snapshot.hasError){
//           return SomethingwentWrong(context);
//         }
//         if(snapshot.connectionState == ConnectionState.done) {
//               return MaterialApp(home: HandleLogin(),);
//         }
//         return Loading(context);
//       },
//     );
//   }
// }
//
// Widget SomethingwentWrong(BuildContext context){
//   return MaterialApp(
//     home: Scaffold(
//       body: Container(
//         height: double.infinity,
//         width:double.infinity,
//         child: Center(
//           child: Text('Something Wrong Contact here \n 09683064033',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Constants.primaryColor),),
//         ),
//       ),
//     ),
//   );
// }
//
// Widget Loading(BuildContext context){
//   return MaterialApp(home: Scaffold(
//     body: Container(width: double.infinity,
//     height:double.infinity,
//     child: Center(child: CircularProgressIndicator()),),
//   ),);
// }
//
// class myHome extends StatefulWidget {
//   @override
//   _myHomeState createState() => _myHomeState();
// }
//
// class _myHomeState extends State<myHome> {
// 
//
//   @override
//   Widget build(BuildContext context) {
//     // final firestoreService = FirestoreService();
//     return MaterialApp(home: LoginPage());
//   }
// }

//
// MultiProvider(providers: [
// ChangeNotifierProvider(create: (context) => ProductProvider()),
// StreamProvider(create:(context) => firestoreService.getProduct(),)
// ],
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Firebase.initializeApp();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ProductProvider,
//         child: MaterialApp(home: Products()));
//   }
// }
