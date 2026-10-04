import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

/// Zepto/Blinkit style browse block for non-food module homes: category rail on
/// the left and a 2-column product grid for the selected category on the right.
class HomeVerticalCategoryView extends StatefulWidget {
  const HomeVerticalCategoryView({super.key});

  @override
  State<HomeVerticalCategoryView> createState() => _HomeVerticalCategoryViewState();
}

class _HomeVerticalCategoryViewState extends State<HomeVerticalCategoryView> {
  final ScrollController _gridController = ScrollController();

  List<CategoryModel>? _sourceList;
  int _selectedIndex = 0;
  List<Item>? _items;
  int _offset = 1;
  int _totalSize = 0;
  bool _loadingMore = false;
  int _requestId = 0;
  bool _skipEmptyCategories = false;

  @override
  void initState() {
    super.initState();
    _gridController.addListener(() {
      if (_gridController.position.pixels >= _gridController.position.maxScrollExtent - 200 &&
          !_loadingMore && _items != null && _items!.length < _totalSize) {
        _loadItems(_offset + 1);
      }
    });
  }

  @override
  void dispose() {
    _gridController.dispose();
    super.dispose();
  }

  void _syncWithCategories(List<CategoryModel>? categories) {
    if (categories == null || categories.isEmpty || identical(categories, _sourceList)) {
      return;
    }
    _sourceList = categories;
    _selectedIndex = 0;
    _skipEmptyCategories = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadItems(1);
      }
    });
  }

  Future<void> _loadItems(int offset) async {
    final List<CategoryModel>? categories = _sourceList;
    if (categories == null || categories.isEmpty) {
      return;
    }
    final int requestId = offset == 1 ? ++_requestId : _requestId;
    setState(() {
      if (offset == 1) {
        _items = null;
        _totalSize = 0;
      } else {
        _loadingMore = true;
      }
    });
    if (offset == 1 && _gridController.hasClients) {
      _gridController.jumpTo(0);
    }

    final ItemModel? model = await Get.find<CategoryController>().categoryServiceInterface
        .getCategoryItemList(categories[_selectedIndex].id.toString(), offset, 'all');
    if (!mounted || requestId != _requestId) {
      return;
    }
    if (offset == 1 && _skipEmptyCategories) {
      if (model != null && (model.items?.isEmpty ?? true) && _selectedIndex < categories.length - 1) {
        _selectedIndex++;
        _loadItems(1);
        return;
      }
      if (model != null && (model.items?.isEmpty ?? true)) {
        _selectedIndex = 0;
      }
      _skipEmptyCategories = false;
    }
    setState(() {
      _loadingMore = false;
      if (model != null) {
        _offset = offset;
        _totalSize = model.totalSize ?? 0;
        _items = offset == 1 ? [...?model.items] : [...?_items, ...?model.items];
      } else if (offset == 1) {
        _items = [];
      }
    });
  }

  void _select(int index) {
    if (index == _selectedIndex) {
      return;
    }
    _skipEmptyCategories = false;
    _selectedIndex = index;
    _loadItems(1);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      final List<CategoryModel>? categories = categoryController.categoryList;
      if (categories != null && categories.isEmpty) {
        return const SizedBox();
      }
      _syncWithCategories(categories);

      final bool isShop = Get.find<SplashController>().module?.moduleType.toString() == AppConstants.ecommerce;
      final bool webWide = ResponsiveHelper.isWeb() && !ResponsiveHelper.isMobile(context);
      final double height = webWide
          ? (MediaQuery.of(context).size.height * 0.78).clamp(520.0, 820.0)
          : (MediaQuery.of(context).size.height * 0.72).clamp(420.0, 680.0);
      final double railWidth = webWide ? 128 : 86;
      final CategoryModel? selected = categories != null && _selectedIndex < categories.length
          ? categories[_selectedIndex] : null;

      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: 'categories'.tr,
              onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: height,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                width: railWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(right: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.15))),
                ),
                child: categories == null
                    ? const _RailShimmer()
                    : ListView.builder(
                        itemCount: categories.length,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        itemBuilder: (context, index) => _RailTile(
                          category: categories[index],
                          selected: index == _selectedIndex,
                          onTap: () => _select(index),
                        ),
                      ),
              ),

              Expanded(
                child: _items == null
                    ? Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ))
                    : _items!.isEmpty
                        ? Center(child: Text(
                            'no_category_item_found'.tr,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          ))
                        : CustomScrollView(
                            controller: _gridController,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                                    mainAxisExtent: 270,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => ItemCard(
                                      item: _items![index],
                                      isPopularItemCart: true,
                                      isShop: isShop,
                                      isFood: false,
                                      fillWidth: MediaQuery.sizeOf(context).width >= 650,
                                      index: index,
                                    ),
                                    childCount: _items!.length,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: _loadingMore
                                    ? Padding(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        child: Center(child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                        )),
                                      )
                                    : selected != null
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              Dimensions.paddingSizeSmall, 0,
                                              Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault,
                                            ),
                                            child: OutlinedButton(
                                              onPressed: () => Get.toNamed(
                                                RouteHelper.getCategoryItemRoute(selected.id, selected.name ?? ''),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Theme.of(context).primaryColor,
                                                side: BorderSide(color: Theme.of(context).primaryColor),
                                              ),
                                              child: Text(
                                                '${'view_all'.tr} ${selected.name ?? ''}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                              ),
                            ],
                          ),
              ),
            ]),
          ),
        ]),
      );
    });
  }
}

class _RailTile extends StatelessWidget {
  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;
  const _RailTile({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.08) : Colors.transparent,
          border: Border(right: BorderSide(color: selected ? primary : Colors.transparent, width: 3)),
        ),
        child: Column(children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomImage(
              image: category.imageFullUrl ?? '',
              height: 52,
              width: 52,
              fit: BoxFit.cover,
              placeholder: Images.placeholder,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            category.name ?? '',
            style: (selected ? robotoBold : robotoRegular).copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: selected ? primary : Theme.of(context).textTheme.bodyMedium!.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

class _RailShimmer extends StatelessWidget {
  const _RailShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(height: 8, width: 48, color: Theme.of(context).disabledColor.withOpacity(0.15)),
        ]),
      ),
    );
  }
}
