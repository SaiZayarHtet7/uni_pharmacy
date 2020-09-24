import 'package:flutter/cupertino.dart';
import 'package:uni_pharmacy/models/product_model.dart';
import 'package:uni_pharmacy/service/firestore_service.dart';
import 'package:uuid/uuid.dart';

class ProductProvider with ChangeNotifier {

  final firestoreService = FirestoreService();
  String _name;
  int _price;
  String _productid;
  var uuid=Uuid();

  //Getters
  String get name => _name;

  int get pricec => _price;

//setters
  changeName(String value) {
    _name = value;
    notifyListeners();
  }
  changePrice(String value){
    _price =int.parse(value);
    notifyListeners();
  }

  loadValues(Product_Model productModel){
   _name= productModel.name;
   _price=productModel.price;
   _productid=productModel.product_id;
  }



  saveProduct(){
    print(_productid);
    print('$name,$_price');
    if(_productid== null) {
      var newProduct = Product_Model(
          name: name, price: pricec, product_id: uuid.v4());
      // firestoreService.saveProduct(newProduct);
    }
      else{
      var updateProduct = Product_Model(name:  name, price: pricec,product_id: _productid
      );
      // firestoreService.saveProduct(updateProduct);
    }
    }

    removeProduct(String ProductID){
      // firestoreService.removeProduct(ProductID);
    }
  }

