import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ModuleHelper {

  static ModuleModel? getModule() {
    return Get.find<SplashController>().module;
  }

  static ModuleModel? getCacheModule() {
    return Get.find<SplashController>().cacheModule;
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }

  /// Falls back to food = horizontal, everything else = vertical when the API omits `category_layout`.
  static bool isVerticalCategoryLayout([ModuleModel? module]) {
    module ??= getModule() ?? getCacheModule();
    if (module == null) {
      return false;
    }
    if (module.categoryLayout != null && module.categoryLayout!.isNotEmpty) {
      return module.categoryLayout == 'vertical';
    }
    return module.moduleType != AppConstants.food;
  }

}