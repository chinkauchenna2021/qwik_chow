import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  String? description;
  String? discount;
  String? discountType;
  Timestamp? expiresAt;
  String? image;
  bool? isEnabled;
  bool? isPublic = false;
  String? code;
  String? id;
  String? resturantId;

  OfferModel(
      {this.description,
        this.discount,
        this.discountType,
        this.expiresAt,
        this.image,
        this.isEnabled,
        this.isPublic,
        this.code,
        this.id,
        this.resturantId});

  OfferModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    discount = json['discount'];
    discountType = json['discountType'];
    expiresAt = json['expiresAt'];
    image = json['image'];
    isEnabled = json['isEnabled'];
    isPublic = json['isPublic']??false;
    code = json['code'];
    id = json['id'];
    resturantId = json['resturant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['discount'] = this.discount;
    data['discountType'] = this.discountType;
    data['expiresAt'] = this.expiresAt;
    data['image'] = this.image;
    data['isEnabled'] = this.isEnabled;
    data['isPublic'] = this.isPublic;
    data['code'] = this.code;
    data['id'] = this.id;
    data['resturant_id'] = this.resturantId;
    return data;
  }
}
