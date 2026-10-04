import 'dart:convert';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';

class PlaceMultiStoreEntry {
  final int storeId;
  final double distance;
  final String? orderNote;
  final String? couponCode;

  PlaceMultiStoreEntry({
    required this.storeId,
    required this.distance,
    this.orderNote,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'store_id': storeId,
      'distance': distance,
    };
    if (orderNote != null && orderNote!.isNotEmpty) {
      data['order_note'] = orderNote;
    }
    if (couponCode != null && couponCode!.isNotEmpty) {
      data['coupon_code'] = couponCode;
    }
    return data;
  }
}

class PlaceMultiOrderBodyModel {
  final List<OnlineCart> cart;
  final double? couponDiscountAmount;
  final double orderAmount;
  final String? orderType;
  final String paymentMethod;
  final String? scheduleAt;
  final double? discountAmount;
  final double taxAmount;
  final String? address;
  final String? latitude;
  final String? longitude;
  final int? senderZoneId;
  final String contactPersonName;
  final String? contactPersonNumber;
  final AddressModel? receiverDetails;
  final String? addressType;
  final String? parcelCategoryId;
  final String? chargePayer;
  final String streetNumber;
  final String house;
  final String floor;
  final String dmTips;
  final String unavailableItemNote;
  final String deliveryInstruction;
  final int cutlery;
  final int partialPayment;
  final int guestId;
  final int isBuyNow;
  final String? guestEmail;
  final double? extraPackagingAmount;
  final int? createNewUser;
  final String? password;
  final List<PlaceMultiStoreEntry> stores;

  PlaceMultiOrderBodyModel({
    required this.cart,
    required this.couponDiscountAmount,
    required this.orderAmount,
    required this.orderType,
    required this.paymentMethod,
    required this.scheduleAt,
    required this.discountAmount,
    required this.taxAmount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.senderZoneId,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.receiverDetails,
    required this.addressType,
    required this.parcelCategoryId,
    required this.chargePayer,
    required this.streetNumber,
    required this.house,
    required this.floor,
    required this.dmTips,
    required this.unavailableItemNote,
    required this.deliveryInstruction,
    required this.cutlery,
    required this.partialPayment,
    required this.guestId,
    required this.isBuyNow,
    required this.guestEmail,
    required this.extraPackagingAmount,
    required this.createNewUser,
    required this.password,
    required this.stores,
  });

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['cart'] = jsonEncode(cart.map((v) => v.toJson()).toList());
    if (couponDiscountAmount != null) {
      data['coupon_discount_amount'] = couponDiscountAmount.toString();
    }
    data['order_amount'] = orderAmount.toString();
    data['order_type'] = orderType!;
    data['payment_method'] = paymentMethod;
    if (scheduleAt != null) {
      data['schedule_at'] = scheduleAt!;
    }
    data['discount_amount'] = discountAmount.toString();
    data['tax_amount'] = taxAmount.toString();
    data['address'] = address ?? '';
    if (receiverDetails != null) {
      data['receiver_details'] = jsonEncode(receiverDetails!.toJson());
    }
    data['latitude'] = latitude ?? '';
    data['longitude'] = longitude ?? '';
    if (senderZoneId != null) {
      data['sender_zone_id'] = senderZoneId.toString();
    }
    data['contact_person_name'] = contactPersonName;
    data['contact_person_number'] = contactPersonNumber ?? '';
    data['address_type'] = addressType ?? '';
    if (parcelCategoryId != null) {
      data['parcel_category_id'] = parcelCategoryId!;
    }
    if (chargePayer != null) {
      data['charge_payer'] = chargePayer!;
    }
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    data['dm_tips'] = dmTips;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['cutlery'] = cutlery.toString();
    data['partial_payment'] = partialPayment.toString();
    if (guestId != 0) {
      data['guest_id'] = guestId.toString();
    }
    data['is_buy_now'] = isBuyNow.toString();
    if (guestEmail != null) {
      data['contact_person_email'] = guestEmail!;
    }
    data['extra_packaging_amount'] = extraPackagingAmount.toString();
    data['create_new_user'] = createNewUser.toString();
    if (password != null) {
      data['password'] = password!;
    }
    data['stores'] = jsonEncode(stores.map((e) => e.toJson()).toList());
    return data;
  }
}
