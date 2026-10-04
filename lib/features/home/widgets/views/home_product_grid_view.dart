import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';

class HomeProductGridView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const HomeProductGridView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShopModule = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;

        return (itemList != null)
            ? itemList.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: TitleWidget(
                          title: isShopModule ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                          image: Images.mostPopularIcon,
                          onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(true, false)),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: Dimensions.paddingSizeDefault,
                          crossAxisSpacing: Dimensions.paddingSizeDefault,
                          mainAxisExtent: 285,
                        ),
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: ItemCard(
                              isPopularItem: !isShopModule,
                              isPopularItemCart: true,
                              item: itemList[index],
                              isShop: isShopModule,
                              isFood: isFood,
                              index: index,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox()
            : const ItemShimmerView(isPopularItem: true);
      }),
    );
  }
}
