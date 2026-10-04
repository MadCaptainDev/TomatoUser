import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/store_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/item_shimmer.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final bool isFeatured;
  final bool? isFoodOrGrocery;
  final bool useTwoColumnItemGrid;
  const ItemsView(
      {super.key,
      required this.stores,
      required this.items,
      required this.isStore,
      this.isScrollable = false,
      this.shimmerLength = 20,
      this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
      this.noDataText,
      this.isCampaign = false,
      this.inStorePage = false,
      this.isFeatured = false,
      this.isFoodOrGrocery = true,
      this.useTwoColumnItemGrid = false});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  @override
  Widget build(BuildContext context) {
    final bool twoColumnItemGrid = widget.useTwoColumnItemGrid ||
        (widget.inStorePage &&
            !widget.isStore &&
            (ResponsiveHelper.isMobile(context) || ResponsiveHelper.isWeb()));
    final bool webWideStore = widget.isStore &&
        ResponsiveHelper.isWeb() &&
        !ResponsiveHelper.isMobile(context);
    final int itemCrossAxisCount = twoColumnItemGrid
        ? 2
        : webWideStore
            ? 2
            : ResponsiveHelper.isMobile(context)
                ? 1
                : 3;
    final double itemMainAxisExtent = twoColumnItemGrid
        ? 285
        : webWideStore || (ResponsiveHelper.isDesktop(context) && widget.isStore)
            ? 220
            : ResponsiveHelper.isMobile(context)
                ? widget.stores != null && widget.isStore
                    ? 225
                    : 122
                : 122;
    final double itemCrossAxisSpacing = twoColumnItemGrid
        ? Dimensions.paddingSizeSmall
        : ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeExtremeLarge
            : Dimensions.paddingSizeLarge;
    final double itemMainAxisSpacing = twoColumnItemGrid
        ? Dimensions.paddingSizeSmall
        : ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeExtremeLarge
            : widget.stores != null && widget.isStore
                ? Dimensions.paddingSizeLarge
                : Dimensions.paddingSizeSmall;
    final bool isFoodModule = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() == 'food';
    final bool isShopModule = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    return Column(children: [
      !isNull
          ? length > 0
              ? GridView.builder(
                  key: UniqueKey(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: itemCrossAxisSpacing,
                    mainAxisSpacing: itemMainAxisSpacing,
                    mainAxisExtent: itemMainAxisExtent,
                    crossAxisCount: itemCrossAxisCount,
                  ),
                  physics: widget.isScrollable
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: widget.isScrollable ? false : true,
                  itemCount: length,
                  padding: widget.padding,
                  itemBuilder: (context, index) {
                    return widget.stores != null && widget.isStore
                        ? widget.isFoodOrGrocery! && widget.isStore
                            ? StoreCardWidget(store: widget.stores![index])
                            : StoreCardWithDistance(
                                store: widget.stores![index]!,
                                fromAllStore: true)
                        : twoColumnItemGrid
                            ? ItemCard(
                                item: widget.items![index]!,
                                isFood: isFoodModule,
                                isShop: isShopModule,
                                isPopularItemCart: true,
                                fillWidth: !ResponsiveHelper.isMobile(context),
                                inStore: widget.inStorePage,
                                index: index,
                              )
                            : ItemWidget(
                                isStore: widget.isStore,
                                item:
                                    widget.isStore ? null : widget.items![index],
                                isFeatured: widget.isFeatured,
                                store: widget.isStore
                                    ? widget.stores![index]
                                    : null,
                                index: index,
                                length: length,
                                isCampaign: widget.isCampaign,
                                inStore: widget.inStorePage,
                              );
                  },
                )
              : NoDataScreen(
                  text: widget.noDataText ??
                      (widget.isStore
                          ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'no_restaurant_available'.tr
                              : 'no_store_available'.tr
                          : 'no_item_available'.tr),
                )
          : GridView.builder(
              key: UniqueKey(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: itemCrossAxisSpacing,
                mainAxisSpacing: itemMainAxisSpacing,
                mainAxisExtent: (widget.isStore || twoColumnItemGrid) ? itemMainAxisExtent : 110,
                crossAxisCount: widget.isStore
                    ? (webWideStore
                        ? 2
                        : (ResponsiveHelper.isMobile(context) ? 1 : 3))
                    : itemCrossAxisCount,
              ),
              physics: widget.isScrollable
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              shrinkWrap: widget.isScrollable ? false : true,
              itemCount: widget.shimmerLength,
              padding: widget.padding,
              itemBuilder: (context, index) {
                return widget.isStore
                    ? widget.isFoodOrGrocery!
                        ? const StoreCardShimmer()
                        : const NewOnShimmerView()
                    : ItemShimmer(
                        isEnabled: isNull,
                        isStore: widget.isStore,
                        hasDivider: index != widget.shimmerLength - 1);
              },
            ),
    ]);
  }
}

class NewOnShimmerView extends StatelessWidget {
  const NewOnShimmerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Stack(children: [
        Container(
          // width: fromAllStore ?  MediaQuery.of(context).size.width : 260,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusDefault),
                    topRight: Radius.circular(Dimensions.radiusDefault)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                      ),
                      child: Icon(Icons.favorite_border,
                          color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 95),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 100,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.blue, size: 15),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                              child: Container(
                                height: 10,
                                width: 100,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ]),
                        ]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 10,
                            width: 70,
                            padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 65,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        Positioned(
          top: 60,
          left: 15,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 65,
                width: 65,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
