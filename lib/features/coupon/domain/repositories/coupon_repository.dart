import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future getList(
      {int? offset,
      bool couponList = false,
      bool taxiCouponList = false}) async {
    if (couponList) {
      return await _getCouponList();
    } else if (taxiCouponList) {
      return await _getTaxiCouponList();
    }
  }

  Future<List<CouponModel>?> _getCouponList() async {
    List<CouponModel>? couponList;
    Response response = await apiClient.getData(AppConstants.couponUri);
    if (response.statusCode == 200) {
      couponList = [];
      response.body.forEach((category) {
        CouponModel coupon = CouponModel.fromJson(category);
        coupon.toolTip = JustTheController();
        couponList!.add(coupon);
      });
    }
    return couponList;
  }

  Future<List<CouponModel>?> _getTaxiCouponList() async {
    List<CouponModel>? taxiCouponList;
    Response response = await apiClient.getData(AppConstants.taxiCouponUri);
    if (response.statusCode == 200) {
      taxiCouponList = [];
      response.body.forEach(
          (category) => taxiCouponList!.add(CouponModel.fromJson(category)));
    }
    return taxiCouponList;
  }

  @override
  Future<CouponModel?> applyCoupon(String couponCode, int? storeID) async {
    CouponModel? couponModel;
    Response response = await apiClient
        .getData('${AppConstants.couponApplyUri}$couponCode&store_id=$storeID');
    if (response.statusCode == 200) {
      couponModel = CouponModel.fromJson(response.body);
    }
    return couponModel;
  }

  Future<String> createReferalCoupon(int? storeID) async {
    Response response = await apiClient.postData(
      AppConstants.createReferalCoupon, // Define API endpoint in constants
      {"store_id": storeID},
    );

    if (response.statusCode == 200) {
      print(response.body);
      return response.body['coupon_code'] ??
          ''; // Safely return the coupon code
    } else {
      print("Error: ${response.body}");

      // Check if the response body contains the existing coupon code
      if (response.statusCode == 403 &&
          response.body != null &&
          response.body is Map &&
          response.body.containsKey('existing_coupon_code')) {
        return response
            .body['existing_coupon_code']; // Return existing coupon if present
      }

      return ''; // Return empty string to prevent null errors
    }
  }

  @override
  Future<CouponModel?> applyTaxiCoupon(
      String couponCode, int? providerId) async {
    CouponModel? taxiCouponModel;
    Response response = await apiClient.getData(
        '${AppConstants.taxiCouponApplyUri}$couponCode&provider_id=$providerId');
    if (response.statusCode == 200) {
      taxiCouponModel = CouponModel.fromJson(response.body);
    }
    return taxiCouponModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
