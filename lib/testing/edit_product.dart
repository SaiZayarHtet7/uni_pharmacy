import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_pharmacy/models/product_model.dart';
import '../providers/product_provider.dart';

class EditProduct extends  StatefulWidget{

  final Product_Model productModel;
  EditProduct([this.productModel]);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {

  final product_name_controller = TextEditingController();
  final product_price_controller = TextEditingController();

  @override
  void initState() {
    Firebase.initializeApp();
    // TODO: implement initState
    if(widget.productModel == null){
      product_name_controller.text="";
      product_price_controller.text="";
      new Future.delayed(Duration.zero,(){
        final productProvider =  Provider.of<ProductProvider>(context,listen: false);
        productProvider.loadValues(Product_Model( ));
      });
    }else{
      product_name_controller.text=widget.productModel.name ;
      product_price_controller.text=widget.productModel.price.toString() ;
      new Future.delayed(Duration.zero,(){
        final productProvider =  Provider.of<ProductProvider>(context,listen: false);
        productProvider.loadValues(widget.productModel);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    product_name_controller.dispose();
    product_price_controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final productProvider =  Provider.of<ProductProvider>(context);



    // TODO: implement build
    return Scaffold(appBar: AppBar(title: Text('Edit Product'),),
    body: Container(
      padding: EdgeInsets.all(10.0),
        child: ListView(children:<Widget> [
          TextField(
            decoration: InputDecoration(hintText: 'Product Name'),
            controller: product_name_controller,
          ),
          TextField(
            decoration: InputDecoration(hintText:'Product Price'),
            controller: product_price_controller,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10.0,),
          RaisedButton(child: Text('Save'),
            onPressed: (){
              ///for saving
              productProvider.changeName(product_name_controller.text);
              productProvider.changePrice(product_price_controller.text);
              productProvider.saveProduct();
              Navigator.of(context).pop();
            },
          ),
          RaisedButton(child: Text('Delete',style:TextStyle(color: Colors.white),),
          color: Colors.red,
          onPressed: (){
        productProvider.removeProduct(widget.productModel.product_id);
        Navigator.of(context).pop();
          },)
        ],),
    ),);
  }
}