import 'package:flutter/material.dart';
import 'package:uni_pharmacy/models/product_model.dart';
import 'package:uni_pharmacy/testing/edit_product.dart';
import 'package:provider/provider.dart';

class Products extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<List<Product_Model>>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Products'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditProduct()));
              },
            )
          ],
        ),
        body: (product != null)
            ? ListView.builder(
                itemCount: product.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(product[index].name),
                      trailing: Text(product[index].price.toString()),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditProduct(product[index])));
                      });
                })
            : Center(child: CircularProgressIndicator()));
  }
}
