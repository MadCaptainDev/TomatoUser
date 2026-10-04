import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_item_view.dart';
import 'package:sixam_mart/common/widgets/web_item_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/search/widgets/custom_check_box_widget.dart';
import 'package:sixam_mart/features/store/widgets/customizable_space_bar_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_banner_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_description_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/widgets/store_details_screen_shimmer_widget.dart';

import '../widgets/bottom_cart_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  const StoreScreen(
      {super.key,
      required this.store,
      required this.fromModule,
      this.slug = ''});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String referalcoupon = '';

  @override
  void initState() {
    super.initState();
    initDataCall();
  }

  Future getReferalCoupon() async {
    referalcoupon = await Get.find<CouponController>()
        .createReferalCoupon(widget.store!.id ?? 1);
    print('Referral: $referalcoupon');

    // Copy the referral coupon code to the clipboard
    Clipboard.setData(ClipboardData(text: referalcoupon));
    Get.snackbar(
      'Referral Coupon',
      'Coupon code copied: $referalcoupon',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> initDataCall() async {
    if (Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>()
        .getStoreDetails(Store(id: widget.store!.id), widget.fromModule,
            slug: widget.slug)
        .then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(
        widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(
        widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(
        widget.store!.id ?? Get.find<StoreController>().store!.id,
        1,
        'all',
        false);

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      } else {
        if (!Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GetBuilder<StoreController>(builder: (storeController) {
          return GetBuilder<CategoryController>(builder: (categoryController) {
            Store? store;
            if (storeController.store != null &&
                storeController.store!.name != null &&
                categoryController.categoryList != null) {
              store = storeController.store;
              storeController.setCategoryList();
            }

            return (storeController.store != null &&
                    storeController.store!.name != null &&
                    categoryController.categoryList != null)
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            CustomAppBar(title: 'Store Detail', showHome: true),
                            SizedBox(
                              height: 20,
                            ),
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeLarge,
                                    horizontal: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Container(
                                    width: Get.width,
                                    height: Get.height / 5,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusLarge),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            Dimensions.radiusDefault),
                                      ),
                                      child: CustomImage(
                                        image:
                                            store!.coverPhotoFullUrl.toString(),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top:
                                      -5, // Adjust to position it on top center
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape
                                          .circle, // Primary color border
                                    ),
                                    child: CircleAvatar(
                                      radius: 40,
                                      child: CustomImage(
                                          image: store!.logoFullUrl.toString()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            store.discount != null
                                ? Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(
                                            Dimensions.radiusLarge),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                    child: Text(
                                      '${store.discount!.discountType == 'percent' ? '${store.discount!.discount}% ${'off'.tr}' : '${PriceConverter.convertPrice(store.discount!.discount)} ${'off'.tr}'} '
                                      '${'on_all_products'.tr}${store.discount!.minPurchase != 0 ? ', ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store.discount!.minPurchase)}' : ''}'
                                      '${store.discount!.maxDiscount != 0 ? ', ${'up_to_maximum_of'.tr} ${PriceConverter.convertPrice(store.discount!.maxDiscount)}' : ''}, '
                                      '${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store.discount!.startTime!)} - ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : const SizedBox(),
                            !Get.find<StoreController>().isStoreOpenNow(store.active!, store.schedules) || store.open != 1
                                ? Container(
                                    width: double.infinity,
                                    color: Theme.of(context).colorScheme.error,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall,
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(
                                      Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                          ? 'restaurant_is_closed_now'.tr
                                          : 'store_is_closed_now'.tr,
                                      style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox(),
                            Container(
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.only(
                                  bottom: 0, left: 20, right: 20),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  height: 100,
                                  color: Theme.of(context).cardColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    store.name ?? '',
                                                    style:
                                                        robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                              ],
                                            ),
                                            if (store.isLocationVisible) ...[
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text(
                                                store.address ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'minimum_order'.tr,
                                                    style:
                                                        robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Favourite Icon
                                      GetBuilder<FavouriteController>(
                                        builder: (favouriteController) {
                                          bool isWished = favouriteController
                                              .wishStoreIdList
                                              .contains(store!.id);
                                          return InkWell(
                                            onTap: () {
                                              if (AuthHelper.isLoggedIn()) {
                                                isWished
                                                    ? favouriteController
                                                        .removeFromFavouriteList(
                                                            store!.id, true)
                                                    : favouriteController
                                                        .addToFavouriteList(
                                                            null,
                                                            store!.id,
                                                            true);
                                              } else {
                                                showCustomSnackBar(
                                                    'you_are_not_logged_in'.tr);
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault),
                                              ),
                                              padding: const EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Icon(
                                                isWished
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isWished
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .disabledColor,
                                                size: 24,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),

                                      // Share Icon
                                      AppConstants.webHostedUrl.isNotEmpty
                                          ? InkWell(
                                              onTap: () => Get.find<StoreController>().shareStore(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                ),
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeExtraSmall),
                                                child: const Icon(Icons.share,
                                                    size: 24),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      (ResponsiveHelper.isDesktop(context) &&
                              storeController.recommendedItemModel != null &&
                              storeController
                                  .recommendedItemModel!.items!.isNotEmpty)
                          ? SliverToBoxAdapter(
                              child: Container(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.10),
                                child: Center(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    height: ResponsiveHelper.isDesktop(context)
                                        ? 300
                                        : 125,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Text('recommended'.tr,
                                            style: robotoMedium),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        SizedBox(
                                          height: 250,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: storeController
                                                .recommendedItemModel!
                                                .items!
                                                .length,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                width: 225,
                                                padding: const EdgeInsets.only(
                                                    right: Dimensions
                                                        .paddingSizeSmall,
                                                    left: Dimensions
                                                        .paddingSizeExtraSmall),
                                                margin: const EdgeInsets.only(
                                                    right: Dimensions
                                                        .paddingSizeSmall),
                                                child: WebItemWidget(
                                                  isStore: false,
                                                  item: storeController
                                                      .recommendedItemModel!
                                                      .items![index],
                                                  store: null,
                                                  index: index,
                                                  length: null,
                                                  isCampaign: false,
                                                  inStore: true,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: SizedBox()),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: Dimensions.paddingSizeSmall)),

                      ///web view..
                      ResponsiveHelper.isDesktop(context)
                          ? SliverToBoxAdapter(
                              child: FooterView(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeSmall),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 175,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: storeController
                                                      .categoryList!.length,
                                                  padding: const EdgeInsets
                                                      .only(
                                                      left: Dimensions
                                                          .paddingSizeSmall),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        storeController
                                                            .setCategoryIndex(
                                                                index,
                                                                itemSearching:
                                                                    storeController
                                                                        .isSearching);
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            bottom: Dimensions
                                                                .paddingSizeSmall),
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeSmall,
                                                              vertical: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                      begin: Alignment
                                                                          .bottomRight,
                                                                      end: Alignment
                                                                          .topLeft,
                                                                      colors: <Color>[
                                                                index == storeController.categoryIndex
                                                                    ? Theme.of(
                                                                            context)
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                            0.50)
                                                                    : Colors
                                                                        .transparent,
                                                                index ==
                                                                        storeController
                                                                            .categoryIndex
                                                                    ? Theme.of(
                                                                            context)
                                                                        .cardColor
                                                                    : Colors
                                                                        .transparent,
                                                              ])),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  storeController
                                                                      .categoryList![
                                                                          index]
                                                                      .name!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: index ==
                                                                          storeController
                                                                              .categoryIndex
                                                                      ? robotoMedium.copyWith(
                                                                          fontSize: Dimensions
                                                                              .fontSizeSmall,
                                                                          color: Theme.of(context)
                                                                              .primaryColor)
                                                                      : robotoRegular.copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: storeController
                                                        .categoryList!.length *
                                                    50,
                                                width: 1,
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeLarge),
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeExtraSmall),
                                                  height: 45,
                                                  width: 430,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.40)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _searchController,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .search,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        0),
                                                            hintText:
                                                                'search_for_items'
                                                                    .tr,
                                                            hintStyle: robotoRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusSmall),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),
                                                            filled: true,
                                                            fillColor: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            isDense: true,
                                                            prefixIcon: Icon(
                                                                Icons.search,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        0.50)),
                                                          ),
                                                          onSubmitted:
                                                              (String? value) {
                                                            if (value!
                                                                .isNotEmpty) {
                                                              Get.find<
                                                                      StoreController>()
                                                                  .getStoreSearchItemList(
                                                                _searchController
                                                                    .text
                                                                    .trim(),
                                                                widget.store!.id
                                                                    .toString(),
                                                                1,
                                                                storeController
                                                                    .type,
                                                              );
                                                            }
                                                          },
                                                          onChanged: (String?
                                                              value) {},
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      !storeController
                                                              .isSearching
                                                          ? CustomButton(
                                                              radius: Dimensions
                                                                  .radiusSmall,
                                                              height: 40,
                                                              width: 74,
                                                              buttonText:
                                                                  'search'.tr,
                                                              isBold: false,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              onPressed: () {
                                                                storeController
                                                                    .getStoreSearchItemList(
                                                                  _searchController
                                                                      .text
                                                                      .trim(),
                                                                  widget
                                                                      .store!.id
                                                                      .toString(),
                                                                  1,
                                                                  storeController
                                                                      .type,
                                                                );
                                                              },
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                _searchController
                                                                    .text = '';
                                                                storeController
                                                                    .initSearchData();
                                                                storeController
                                                                    .changeSearchStatus();
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall)),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 3,
                                                                    horizontal:
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                child: const Icon(
                                                                    Icons.clear,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                (Get.find<SplashController>()
                                                            .configModel!
                                                            .moduleConfig!
                                                            .module!
                                                            .vegNonVeg! &&
                                                        Get.find<
                                                                SplashController>()
                                                            .configModel!
                                                            .toggleVegNonVeg!)
                                                    ? SizedBox(
                                                        width: 300,
                                                        height: 30,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: Get.find<
                                                                  ItemController>()
                                                              .itemTypeList
                                                              .length,
                                                          padding: const EdgeInsets
                                                              .only(
                                                              left: Dimensions
                                                                  .paddingSizeSmall),
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return InkWell(
                                                              // onTap: () => storeController.setCategoryIndex(index),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    right: Dimensions
                                                                        .paddingSizeSmall),
                                                                child:
                                                                    CustomCheckBoxWidget(
                                                                  title: Get.find<
                                                                          ItemController>()
                                                                      .itemTypeList[
                                                                          index]
                                                                      .tr,
                                                                  value: storeController
                                                                          .type ==
                                                                      Get.find<ItemController>()
                                                                              .itemTypeList[
                                                                          index],
                                                                  onClick: () {
                                                                    if (storeController
                                                                        .isSearching) {
                                                                      storeController
                                                                          .getStoreSearchItemList(
                                                                        storeController
                                                                            .searchText,
                                                                        widget
                                                                            .store!
                                                                            .id
                                                                            .toString(),
                                                                        1,
                                                                        Get.find<ItemController>()
                                                                            .itemTypeList[index],
                                                                      );
                                                                    } else {
                                                                      storeController.getStoreItemList(
                                                                          storeController
                                                                              .store!
                                                                              .id,
                                                                          1,
                                                                          Get.find<ItemController>()
                                                                              .itemTypeList[index],
                                                                          true);
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            PaginatedListView(
                                              scrollController:
                                                  scrollController,
                                              onPaginate: (int? offset) {
                                                if (storeController
                                                    .isSearching) {
                                                  storeController
                                                      .getStoreSearchItemList(
                                                    storeController.searchText,
                                                    widget.store!.id.toString(),
                                                    offset!,
                                                    storeController.type,
                                                  );
                                                } else {
                                                  storeController
                                                      .getStoreItemList(
                                                          widget.store!.id ??
                                                              storeController
                                                                  .store!.id,
                                                          offset!,
                                                          storeController.type,
                                                          false);
                                                }
                                              },
                                              totalSize:
                                                  storeController.isSearching
                                                      ? storeController
                                                          .storeSearchItemModel
                                                          ?.totalSize
                                                      : storeController
                                                          .storeItemModel
                                                          ?.totalSize,
                                              offset:
                                                  storeController.isSearching
                                                      ? storeController
                                                          .storeSearchItemModel
                                                          ?.offset
                                                      : storeController
                                                          .storeItemModel
                                                          ?.offset,
                                              itemView: WebItemsView(
                                                isStore: false,
                                                stores: null,
                                                fromStore: true,
                                                items: storeController
                                                        .isSearching
                                                    ? storeController
                                                        .storeSearchItemModel
                                                        ?.items
                                                    : (storeController
                                                                .categoryList!
                                                                .isNotEmpty &&
                                                            storeController
                                                                    .storeItemModel !=
                                                                null)
                                                        ? storeController
                                                            .storeItemModel!
                                                            .items
                                                        : null,
                                                inStorePage: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeSmall,
                                                  vertical: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: SizedBox()),

                      ResponsiveHelper.isDesktop(context)
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : SliverToBoxAdapter(
                              child: Center(
                                  child: Container(
                              width: Dimensions.webMaxWidth,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              color: Theme.of(context).cardColor,
                              child: Column(children: [
                                ResponsiveHelper.isDesktop(context)
                                    ? const SizedBox()
                                    : StoreDescriptionViewWidget(store: store),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                store?.announcementActive ?? false
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.2)),
                                        ),
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        margin: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeSmall),
                                        child: Row(children: [
                                          Image.asset(Images.announcement,
                                              height: 20, width: 20),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Flexible(
                                              child: Text(
                                                  store?.announcementMessage ??
                                                      '',
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall))),
                                        ]),
                                      )
                                    : const SizedBox(),
                                StoreBannerWidget(
                                    storeController: storeController),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                (!ResponsiveHelper.isDesktop(context) &&
                                        storeController.recommendedItemModel !=
                                            null &&
                                        storeController.recommendedItemModel!
                                            .items!.isNotEmpty)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('recommended_items'.tr,
                                              style: robotoMedium),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          SizedBox(
                                            height: ResponsiveHelper.isDesktop(
                                                    context)
                                                ? 150
                                                : 130,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: storeController
                                                  .recommendedItemModel!
                                                  .items!
                                                  .length,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: ResponsiveHelper
                                                          .isDesktop(context)
                                                      ? const EdgeInsets
                                                          .symmetric(
                                                          vertical: 20)
                                                      : const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                  child: Container(
                                                    width: ResponsiveHelper
                                                            .isDesktop(context)
                                                        ? 500
                                                        : 300,
                                                    padding: const EdgeInsets
                                                        .only(
                                                        right: Dimensions
                                                            .paddingSizeSmall,
                                                        left: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    margin: const EdgeInsets
                                                        .only(
                                                        right: Dimensions
                                                            .paddingSizeSmall),
                                                    child: ItemWidget(
                                                      isStore: false,
                                                      item: storeController
                                                          .recommendedItemModel!
                                                          .items![index],
                                                      store: null,
                                                      index: index,
                                                      length: null,
                                                      isCampaign: false,
                                                      inStore: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ]),
                            ))),

                      ResponsiveHelper.isDesktop(context)
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : (storeController.categoryList!.isNotEmpty)
                              ? SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SliverDelegate(
                                      height: 90,
                                      child: Center(
                                          child: Container(
                                        width: Dimensions.webMaxWidth,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                offset: Offset(0, 10),
                                                spreadRadius: 1),
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                blurRadius: 5,
                                                offset: Offset(0, 0.5),
                                                spreadRadius: 0.1),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                              child: Row(children: [
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Text('All Products'.tr,
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault)),
                                                ),
                                                const Expanded(
                                                    child: SizedBox()),
                                                !ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? InkWell(
                                                        onTap: () => Get
                                                            .toNamed(RouteHelper
                                                                .getSearchStoreItemRoute(
                                                                    store!.id)),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .radiusDefault),
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.1),
                                                          ),
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          child: Icon(
                                                              Icons.search,
                                                              size: 28,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                storeController.type.isNotEmpty
                                                    ? VegFilterWidget(
                                                        type: storeController
                                                            .type,
                                                        onSelected:
                                                            (String type) {
                                                          storeController
                                                              .getStoreItemList(
                                                                  storeController
                                                                      .store!
                                                                      .id,
                                                                  1,
                                                                  type,
                                                                  true);
                                                        },
                                                      )
                                                    : const SizedBox(),
                                              ]),
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            SizedBox(
                                              height: 30,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .categoryList!.length,
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeSmall),
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () => storeController
                                                        .setCategoryIndex(
                                                            index),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall,
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      margin: const EdgeInsets
                                                          .only(
                                                          right: Dimensions
                                                              .paddingSizeSmall),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                        color: index ==
                                                                storeController
                                                                    .categoryIndex
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              storeController
                                                                  .categoryList![
                                                                      index]
                                                                  .name!,
                                                              style: index ==
                                                                      storeController
                                                                          .categoryIndex
                                                                  ? robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeSmall,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor)
                                                                  : robotoRegular
                                                                      .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                            ),
                                                          ]),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))),
                                )
                              : const SliverToBoxAdapter(child: SizedBox()),

                      ResponsiveHelper.isDesktop(context)
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : SliverToBoxAdapter(
                              child: Container(
                              width: Dimensions.webMaxWidth,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: PaginatedListView(
                                scrollController: scrollController,
                                onPaginate: (int? offset) =>
                                    storeController.getStoreItemList(
                                        widget.store!.id ??
                                            storeController.store!.id,
                                        offset!,
                                        storeController.type,
                                        false),
                                totalSize:
                                    storeController.storeItemModel?.totalSize,
                                offset: storeController.storeItemModel?.offset,
                                itemView: ItemsView(
                                  isStore: false,
                                  stores: null,
                                  items: (storeController
                                              .categoryList!.isNotEmpty &&
                                          storeController.storeItemModel !=
                                              null)
                                      ? storeController.storeItemModel!.items
                                      : null,
                                  inStorePage: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeSmall,
                                  ),
                                ),
                              ),
                            )),
                    ],
                  )
                : const StoreDetailsScreenShimmerWidget();
          });
        }),
        floatingActionButton:
            GetBuilder<StoreController>(builder: (storeController) {
          return Visibility(
            visible: storeController.showFavButton &&
                Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .orderAttachment! &&
                (storeController.store != null &&
                    storeController.store!.prescriptionOrder!) &&
                Get.find<SplashController>().configModel!.prescriptionStatus! &&
                AuthHelper.isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(2, 2))
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: storeController.currentState == true
                      ? 0
                      : ResponsiveHelper.isDesktop(context)
                          ? 180
                          : 150,
                  height: 30,
                  curve: Curves.linear,
                  child: Center(
                    child: Text(
                      'prescription_order'.tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(
                    RouteHelper.getCheckoutRoute('prescription',
                        storeId: storeController.store!.id),
                    arguments: CheckoutScreen(
                        fromCart: false,
                        cartList: null,
                        storeId: storeController.store!.id),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.prescriptionIcon,
                        height: 25, width: 25),
                  ),
                ),
              ]),
            ),
          );
        }),
        bottomNavigationBar:
            GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty &&
                  !ResponsiveHelper.isDesktop(context)
              ? const BottomCartWidget()
              : const SizedBox();
        }));
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}
