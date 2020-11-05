class UpdatePriceModel {
  int quantity;
  int createdDate;
  String oldPrice;
  String newPrice;
  String prodctName,productPhoto;
  String kind;
  String unit;
  String id;

  UpdatePriceModel({this.id,this.prodctName,this.productPhoto,this.kind, this.quantity,this.unit,this.oldPrice,this.newPrice,this.createdDate,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name':prodctName,
      'product_photo':productPhoto,
      'price_kind': kind,
      'quantity': quantity,
      'unit': unit,
      'old_price':oldPrice,
      'new_price':newPrice,
      'created_date': createdDate
    };
  }
}
