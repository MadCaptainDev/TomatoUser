import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class StoreDiscountHelper {
  static double getCartSubtotalForStore(int? storeId) {
    if (storeId == null) {
      return 0;
    }
    double subtotal = 0;
    for (final cart in Get.find<CartController>().cartList) {
      if (cart.item?.storeId == storeId) {
        subtotal += (cart.item!.price ?? 0) * (cart.quantity ?? 1);
      }
    }
    return subtotal;
  }

  static Store? storeForItem(Item item) {
    final storeController = Get.find<StoreController>();
    if (storeController.store?.id == item.storeId) {
      return storeController.store;
    }
    return null;
  }

  static bool isMinPurchaseMet(Store? store, int? storeId) {
    final discount = store?.discount;
    if (discount == null || (discount.minPurchase ?? 0) == 0) {
      return true;
    }
    return getCartSubtotalForStore(storeId ?? store?.id) >= discount.minPurchase!;
  }

  static bool usesStoreDiscount(Item item, {bool isCampaign = false}) {
    return !isCampaign &&
        item.availableDateStarts == null &&
        (item.storeDiscount ?? 0) > 0;
  }

  static double? getItemDiscount(Item item, {Store? store, bool isCampaign = false}) {
    if (isCampaign || item.availableDateStarts != null) {
      return item.discount;
    }
    if ((item.storeDiscount ?? 0) == 0) {
      return item.discount;
    }
    final resolvedStore = store ?? storeForItem(item);
    if (!isMinPurchaseMet(resolvedStore, item.storeId)) {
      return 0;
    }
    return item.storeDiscount;
  }

  static String? getItemDiscountType(Item item, {Store? store, bool isCampaign = false}) {
    if (getItemDiscount(item, store: store, isCampaign: isCampaign) == 0 &&
        usesStoreDiscount(item, isCampaign: isCampaign)) {
      return null;
    }
    if (isCampaign || item.availableDateStarts != null || (item.storeDiscount ?? 0) == 0) {
      return item.discountType;
    }
    return 'percent';
  }
}
