import 'package:flutter/material.dart';
import 'package:media_view/media_view.dart';
import 'package:media_view/src/full_media_view.dart';
import 'package:media_view/src/utils.dart';

abstract class MediaView extends StatelessWidget {
  MediaView({
    required Key? key,
    this.context,
    this.ignoreFullView = false,
    this.onTap,
  }) : super(key: key) {
    if (ignoreFullView ||
        context == null ||
        MediaViewWrapper.maybeOf(context!)
                ?.listMedia
                .where((element) => element.key == key)
                .isEmpty !=
            true) {
      return;
    }
    MediaViewWrapper.of(context!).listMedia.add(this);
    Utils.log('listMedia ${MediaViewWrapper.of(context!).listMedia.length}');
  }

  final bool ignoreFullView;
  final BuildContext? context;
  final VoidCallback? onTap;

  Widget get child;

  Widget get fullview;

  void onPressed(BuildContext context) {
    if (onTap != null) return onTap!();

    if (ignoreFullView) return;

    FullMediaView.openFullView(this.context ?? context, this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => onPressed(context), child: child);
  }
}
