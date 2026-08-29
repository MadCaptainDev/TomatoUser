import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class StoreFilterButtonWidget extends StatelessWidget {
  const StoreFilterButtonWidget(
      {super.key, this.isSelected, this.onTap, required this.buttonText});

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected == true
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.surface,
          // borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
              color: isSelected == true
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Theme.of(context).primaryColor),

          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected == true
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]),
              child: Image.asset(
                "assets/image/cat_all.png",
                height: 24,
              ),
            ),
            const SizedBox(width: 6),
            Text(buttonText,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight:
                        isSelected == true ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected == true
                        ? Theme.of(context).cardColor
                        : Theme.of(context).primaryColor))
          ],
        ),
      ),
    );

    // InkWell(
    //   onTap: onTap,
    //   child: Container(
    //     height: 35,
    //     padding:
    //         const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
    //     decoration: BoxDecoration(
    //   color: Theme.of(context).colorScheme.surface,
    //   // borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    //   border: Border.all(
    //       color: isSelected == true
    //           ? Theme.of(context).primaryColor.withOpacity(0.3)
    //           : Theme.of(context).disabledColor.withOpacity(0.3)),
    // ),
    //     child: Center(
    //         child: Text(buttonText,
    //             style: robotoRegular.copyWith(
    //                 fontSize: Dimensions.fontSizeSmall,
    //                 fontWeight:
    //                     isSelected == true ? FontWeight.w500 : FontWeight.w400,
    //                 color: isSelected == true
    //                     ? Theme.of(context).primaryColor
    //                     : Theme.of(context).disabledColor))),
    //   ),
    // );
  }
}
