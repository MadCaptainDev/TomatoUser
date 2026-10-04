import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/screens/item_details_screen.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class DeepLinkHelper {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static Uri? _pendingUri;

  static Future<void> init() async {
    if (kIsWeb || !GetPlatform.isMobile) {
      return;
    }

    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _pendingUri = initialUri;
        _scheduleNavigation(initialUri);
      }
    } catch (_) {}

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _scheduleNavigation(uri);
    }, onError: (_) {});
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  static void _scheduleNavigation(Uri uri) {
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (Get.key.currentContext != null) {
        _handleUri(uri);
      } else {
        _pendingUri = uri;
      }
    });
  }

  static void handlePendingIfAny() {
    if (_pendingUri != null) {
      final Uri uri = _pendingUri!;
      _pendingUri = null;
      _handleUri(uri);
    }
  }

  static void _handleUri(Uri uri) {
    if (!_isAppHost(uri)) {
      return;
    }

    final String path = uri.path;
    if (path.contains('item-details')) {
      final int? itemId = int.tryParse(uri.queryParameters['id'] ?? '');
      if (itemId != null) {
        final bool isRestaurant = uri.queryParameters['page'] != 'item';
        Get.toNamed(
          RouteHelper.getItemDetailsRoute(itemId, isRestaurant),
          arguments: ItemDetailsScreen(
            item: Item(id: itemId),
            inStorePage: isRestaurant,
          ),
        );
      }
      return;
    }

    if (path.contains('store') || uri.queryParameters.containsKey('slug')) {
      final String? slug = uri.queryParameters['slug'];
      if (slug != null && slug.isNotEmpty) {
        final int? storeId = int.tryParse(slug);
        Get.toNamed(
          '${RouteHelper.store}?slug=$slug&page=item',
          arguments: StoreScreen(
            store: Store(id: storeId),
            fromModule: false,
            slug: slug,
          ),
        );
      }
    }
  }

  static bool _isAppHost(Uri uri) {
    if (uri.scheme == 'https' && uri.host == Uri.parse(AppConstants.webHostedUrl).host) {
      return true;
    }
    return uri.host == 'app.tomatodeliverz.com';
  }
}
