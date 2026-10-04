import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/module_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/food_category_grid_view.dart';
import 'package:sixam_mart/features/home/widgets/views/home_vertical_category_view.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/features/home/widgets/web/web_new_banner_view_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';

class WebNewHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebNewHomeScreen({super.key, required this.scrollController});

  @override
  State<WebNewHomeScreen> createState() => _WebNewHomeScreenState();
}

class _WebNewHomeScreenState extends State<WebNewHomeScreen> {
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    _isLogin = AuthHelper.isLoggedIn();
    Get.find<SplashController>().getWebSuggestedLocationStatus();

    if (_isLogin) {
      suggestAddressBottomSheet();
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (!Get.find<SplashController>().webSuggestedLocation && active) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog(const Center(
          child: SizedBox(
            height: 470,
            width: 550,
            child: AddressBottomSheetWidget(fromDialog: true),
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      final module = splashController.module;
      final bool pickingModule = module == null && splashController.configModel?.module == null;
      final bool isFood = module != null && module.moduleType.toString() == AppConstants.food;
      final bool isParcel = module != null && (splashController.configModel?.moduleConfig?.module?.isParcel ?? false);

      return Stack(clipBehavior: Clip.none, children: [
        SizedBox(height: context.height),
        CustomScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (pickingModule)
              const SliverToBoxAdapter(child: _WebModulePicker())
            else ...[
              SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      GetBuilder<BannerController>(builder: (bannerController) {
                        final banners = bannerController.bannerImageList;
                        if (banners == null || banners.isEmpty) {
                          return const SizedBox();
                        }
                        return const WebNewBannerViewWidget(isFeatured: false);
                      }),
                      const BadWeatherWidget(),
                      if (!isParcel)
                        GetBuilder<CategoryController>(builder: (categoryController) {
                          final categories = categoryController.categoryList;
                          if (categories != null && categories.isEmpty) {
                            return const SizedBox();
                          }
                          if (ModuleHelper.isVerticalCategoryLayout()) {
                            return const HomeVerticalCategoryView();
                          }
                          if (categories == null) {
                            return const SizedBox(height: 140);
                          }
                          return FoodCategoryGridView(categoryController: categoryController);
                        }),
                    ]),
                  ),
                ),
              ),
              if (isFood)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _WebSliverDelegate(height: 85, child: const AllStoreFilterWidget()),
                ),
              if (isFood)
                SliverToBoxAdapter(
                  child: Center(child: GetBuilder<StoreController>(builder: (storeController) {
                    return SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: PaginatedListView(
                        scrollController: widget.scrollController,
                        totalSize: storeController.storeModel?.totalSize,
                        offset: storeController.storeModel?.offset,
                        onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                        itemView: ItemsView(
                          isStore: true,
                          items: null,
                          isFoodOrGrocery: true,
                          stores: storeController.storeModel?.stores,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtraSmall
                                : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtraSmall
                                : 0,
                          ),
                        ),
                      ),
                    );
                  })),
                ),
            ],
            SliverToBoxAdapter(
              child: FooterView(child: SizedBox(height: pickingModule ? 80 : 24)),
            ),
          ],
        ),
        if (!pickingModule) const Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),
      ]);
    });
  }
}

class _WebModulePicker extends StatelessWidget {
  const _WebModulePicker();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splash) {
      final modules = splash.moduleList;
      return Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 28, 8, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Tomato Deliverz',
                style: robotoBold.copyWith(fontSize: 32, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Food, grocery, pharmacy, shops and parcels.',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 24),
              if (modules == null)
                const _ModulePickerShimmer()
              else if (modules.isEmpty)
                Text('no_module_found'.tr, style: robotoRegular)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 168,
                  ),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      child: InkWell(
                        onTap: () => splash.switchModule(index, true),
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.18)),
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            CustomImage(
                              image: '${module.iconFullUrl}',
                              height: 76,
                              width: 76,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Text(
                              module.moduleName ?? '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
            ]),
          ),
        ),
      );
    });
  }
}

class _ModulePickerShimmer extends StatelessWidget {
  const _ModulePickerShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 168,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
      ),
    );
  }
}

class _WebSliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  _WebSliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_WebSliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
