import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

const double _cellWidth = 72;
const double _cellHeight = 88;
const double _rowGap = 8;

class FoodCategoryGridView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryGridView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    if (categoryController.categoryList!.isEmpty) {
      return const SizedBox();
    }

    final categories = categoryController.categoryList!;
    final columnCount = (categories.length / 2).ceil();

    return SizedBox(
      height: (_cellHeight * 2) + _rowGap + (Dimensions.paddingSizeSmall * 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        itemCount: columnCount,
        itemBuilder: (context, columnIndex) {
          final topIndex = columnIndex * 2;
          final bottomIndex = topIndex + 1;
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Column(
              children: [
                _FoodCategoryCell(
                  categoryController: categoryController,
                  index: topIndex,
                ),
                const SizedBox(height: _rowGap),
                if (bottomIndex < categories.length)
                  _FoodCategoryCell(
                    categoryController: categoryController,
                    index: bottomIndex,
                  )
                else
                  const SizedBox(height: _cellHeight, width: _cellWidth),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FoodCategoryCell extends StatelessWidget {
  final CategoryController categoryController;
  final int index;
  const _FoodCategoryCell({required this.categoryController, required this.index});

  @override
  Widget build(BuildContext context) {
    final category = categoryController.categoryList![index];
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
        category.id,
        category.name!,
      )),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: SizedBox(
        width: _cellWidth,
        height: _cellHeight,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child: CustomImage(
                image: '${category.imageFullUrl}',
                height: 52,
                width: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Flexible(
              child: Text(
                category.name!,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                maxLines: Get.find<LocalizationController>().isLtr ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
