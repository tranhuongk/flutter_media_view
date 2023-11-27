import 'package:flutter/material.dart';
import 'package:media_view/media_view.dart';

class MediaViewWrapper extends InheritedWidget {
  MediaViewWrapper({
    super.key,
    required Widget Function(BuildContext context) builder,
  }) : super(child: Builder(builder: builder));

  final List<MediaView> listMedia = [];

  static MediaViewWrapper of(BuildContext context) {
    final MediaViewWrapper? result = maybeOf(context);
    assert(result != null, 'No MediaViewWrapper found in context');
    return result!;
  }

  static MediaViewWrapper? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MediaViewWrapper>();
  }

  @override
  bool updateShouldNotify(covariant MediaViewWrapper oldWidget) =>
      listMedia != oldWidget.listMedia;
}
