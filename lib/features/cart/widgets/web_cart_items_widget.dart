import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/web_constrained_box.dart';
import 'package:sixam_mart/features/cart/widgets/cart_item_widget.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class WebCardItemsWidget extends StatelessWidget {
  final List<CartModel> cartList;
  const WebCardItemsWidget({super.key, required this.cartList});

  List<Map<String, dynamic>> _groupCartByStore() {
    final Map<int, Map<String, dynamic>> grouped = {};
    for (int index = 0; index < cartList.length; index++) {
      final CartModel cart = cartList[index];
      final int storeId = cart.item!.storeId!;
      grouped.putIfAbsent(storeId, () => {
        'storeId': storeId,
        'storeName': cart.item!.storeName ?? 'Store',
        'entries': <Map<String, dynamic>>[],
      });
      (grouped[storeId]!['entries'] as List<Map<String, dynamic>>).add({'cart': cart, 'index': index});
    }
    return grouped.values.toList();
  }

  double _storeSubtotal(List<Map<String, dynamic>> entries) {
    double subtotal = 0;
    for (final Map<String, dynamic> entry in entries) {
      final CartModel cart = entry['cart'];
      subtotal += (cart.discountedPrice ?? cart.price ?? 0) * (cart.quantity ?? 0);
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<CartController>(
      builder: (cartController) {
        return Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const  BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),

            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Product
              WebConstrainedBox(
                dataLength: cartList.length, minLength: 5, minHeight: 0.6,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ..._groupCartByStore().map((group) {
                    final List<Map<String, dynamic>> entries = group['entries'];
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(group['storeName'], style: robotoMedium)),
                          Text(
                            PriceConverter.convertPrice(_storeSubtotal(entries)),
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                            textDirection: TextDirection.ltr,
                          ),
                        ]),
                      ),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: entries.length,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemBuilder: (context, entryIndex) {
                          final int cartIndex = entries[entryIndex]['index'];
                          final CartModel cart = entries[entryIndex]['cart'];
                          return CartItemWidget(cart: cart, cartIndex: cartIndex, addOns: cartController.addOnsList[cartIndex], isAvailable: cartController.availableList[cartIndex]);
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeSmall),
                        child: TextButton.icon(
                          onPressed: (){
                            final int storeId = group['storeId'];
                            final int moduleId = entries.first['cart'].item!.moduleId!;
                            cartController.forcefullySetModule(moduleId);
                            Get.toNamed(
                              RouteHelper.getStoreRoute(id: storeId, page: 'item'),
                              arguments: StoreScreen(store: Store(id: storeId), fromModule: false),
                            );
                          },
                          icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                          label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                        ),
                      ),
                      const Divider(thickness: 0.5, height: 5),
                    ]);
                  }),


                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]),
          ),
        );
      }
    );
  }
}
