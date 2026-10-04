import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ModuleWidget extends StatelessWidget {
  const ModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      return (ResponsiveHelper.isWeb() && !ResponsiveHelper.isMobile(context) && splashController.configModel!.module == null && splashController.moduleList != null
      && splashController.moduleList!.length > 1) ? Container(
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(Dimensions.radiusExtraLarge)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: splashController.moduleList!.length,
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Tooltip(
                  message: splashController.moduleList![index].moduleName,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                  ),
                  textStyle: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                  preferBelow: false,
                  verticalOffset: 20,
                  child: InkWell(
                    onTap: () => splashController.switchModule(index, false),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        color: (splashController.module != null && splashController.moduleList![index].id == splashController.module!.id)
                            ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).disabledColor.withOpacity(0.2),
                        border: (splashController.module != null && splashController.moduleList![index].id == splashController.module!.id)
                            ? Border.all(color: Theme.of(context).primaryColor) : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: Dimensions.paddingSizeSmall),
                      child: Column(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: SizedBox(
                            height: 28,
                            width: 28,
                            child: CustomImage(
                              image: '${splashController.moduleList![index].iconFullUrl}',
                              height: 28, width: 28, fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          splashController.moduleList![index].moduleName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(
                            fontSize: 9,
                            color: (splashController.module != null && splashController.moduleList![index].id == splashController.module!.id)
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ) : const SizedBox();
    });
  }
}
