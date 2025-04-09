import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class Utils {
  static log(Object? object) {
    if (kDebugMode) print(object);
  }
}

extension UriExtensions on Uri? {
  String? get fileName => this?.pathSegments.lastOrNull;

  bool get isSvg => fileName?.endsWith('svg') == true;

  bool get fromNetwork => this?.toString().startsWith('http') == true;

  bool get fromNetworkSvg => fromNetwork && isSvg;

  bool get fromFile => File(this?.toString() ?? "").existsSync();

  bool get fromFileSvg => fromFile && isSvg;

  bool get fromAsset =>
      !fromFile && !fromNetwork && this?.toString().isNotEmpty == true;

  bool get fromAssetSvg => fromAsset && isSvg;
}
