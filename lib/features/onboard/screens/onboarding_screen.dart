import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: SafeArea(
        child: GetBuilder<OnBoardingController>(
          builder: (onBoardingController) {
            bool showIndicatorAndButton = onBoardingController.selectedIndex <
                onBoardingController.onBoardingList.length - 1;
            return onBoardingController.onBoardingList.isNotEmpty
                ? SafeArea(
                    child: Center(
                        child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(children: [
                              Expanded(
                                  child: PageView.builder(
                                itemCount:
                                    onBoardingController.onBoardingList.length,
                                controller: _pageController,
                                // physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(Images.logo, height: 80),
                                        showIndicatorAndButton &&
                                                onBoardingController
                                                        .onBoardingList[index]
                                                        .imageUrl !=
                                                    ''
                                            ? Padding(
                                                padding: EdgeInsets.all(
                                                    context.height * 0.05),
                                                child: Image.asset(
                                                    onBoardingController
                                                        .onBoardingList[index]
                                                        .imageUrl,
                                                    height:
                                                        context.height * 0.4),
                                              )
                                            : const SizedBox(),
                                        Text(
                                          onBoardingController
                                              .onBoardingList[index].title,
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraLarge,
                                              color:
                                                  Theme.of(context).cardColor),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            height: context.height * 0.015),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeLarge),
                                          child: Text(
                                            onBoardingController
                                                .onBoardingList[index]
                                                .description,
                                            style: robotoRegular.copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    context.height * 0.016,
                                                color: Theme.of(context)
                                                    .cardColor),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ]);
                                },
                                onPageChanged: (index) {
                                  onBoardingController.changeSelectIndex(index);
                                  if (onBoardingController.selectedIndex == 3) {
                                    _configureToRouteInitialPage();
                                  }
                                },
                              )),
                              showIndicatorAndButton
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: _pageIndicators(
                                          onBoardingController, context),
                                    )
                                  : const SizedBox(),
                              SizedBox(height: context.height * 0.05),
                              showIndicatorAndButton
                                  ? InkWell(
                                      onTap: () {
                                        if (onBoardingController
                                                .selectedIndex !=
                                            2) {
                                          _pageController.nextPage(
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.ease);
                                        } else {
                                          _configureToRouteInitialPage();
                                        }
                                      },
                                      child: onBoardingController
                                                  .selectedIndex !=
                                              2
                                          ? Container(
                                              height: 44,
                                              padding: const EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              margin: EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeDefault),
                                              width: 44,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .cardColor)),
                                              child: Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  color: Theme.of(context)
                                                      .cardColor),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              width: context.width / 2,
                                              margin: EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeDefault),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .cardColor)),
                                              child: Text(
                                                'get_started'.tr,
                                                style: robotoRegular.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        context.height * 0.016,
                                                    color: Theme.of(context)
                                                        .cardColor),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                    )
                                  // Padding(
                                  //     padding: const EdgeInsets.all(
                                  //         Dimensions.paddingSizeSmall),
                                  //     child: Row(children: [
                                  //       onBoardingController.selectedIndex == 2
                                  //           ? const SizedBox()
                                  //           : Expanded(
                                  //               child: CustomButton(
                                  //                 transparent: true,
                                  //                 onPressed: () {
                                  //                   _configureToRouteInitialPage();
                                  //                 },
                                  //                 buttonText: 'skip'.tr,
                                  //               ),
                                  //             ),
                                  //       Expanded(
                                  //         child: CustomButton(
                                  //           buttonText: onBoardingController
                                  //                       .selectedIndex !=
                                  //                   2
                                  //               ? 'next'.tr
                                  //               : 'get_started'.tr,
                                  //           onPressed: () {
                                  // if (onBoardingController
                                  //         .selectedIndex !=
                                  //     2) {
                                  //   _pageController.nextPage(
                                  //       duration: const Duration(
                                  //           seconds: 1),
                                  //       curve: Curves.ease);
                                  // } else {
                                  //   _configureToRouteInitialPage();
                                  // }
                                  //           },
                                  //         ),
                                  //       ),
                                  //     ]),
                                  //   )
                                  : const SizedBox(),
                              SizedBox(height: context.height * 0.05),
                            ]))),
                  )
                : const SizedBox();
          },
        ),
      ),
    );
  }

  List<Widget> _pageIndicators(
      OnBoardingController onBoardingController, BuildContext context) {
    List<Container> indicators = [];

    for (int i = 0; i < 3; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 7,
          decoration: BoxDecoration(
            color: i == onBoardingController.selectedIndex
                ? Theme.of(context).cardColor
                : Theme.of(context).disabledColor,
            borderRadius: i == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  )
                : i == 2
                    ? const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      )
                    : BorderRadius.circular(
                        0), // Default for the middle indicator
            border: i == onBoardingController.selectedIndex
                ? Border.all(
                    color:
                        Colors.white, // Border color for the selected indicator
                    width: 2, // Border width for the selected indicator
                  )
                : null,
          ),
        ),
      );
    }

    return indicators;
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>()
          .navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true)
          .then((v) {
        _pageController.jumpToPage(
            Get.find<OnBoardingController>().onBoardingList.length - 2);
      });
    }
  }
}
