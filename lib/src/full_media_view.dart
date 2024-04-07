import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:media_view/media_view.dart';

class FullMediaView extends StatefulWidget {
  const FullMediaView({required this.media, super.key});

  final MediaView media;

  static void openFullView(BuildContext context, MediaView media) {
    if (media.ignoreFullView) return;

    (media.context ?? context)
        .pushTransparentRoute(FullMediaView(media: media));
  }

  @override
  State<FullMediaView> createState() => _FullMediaViewState();
}

class _FullMediaViewState extends State<FullMediaView>
    with TickerProviderStateMixin {
  late final List<MediaView> listMedia =
      MediaViewWrapper.maybeOf(widget.media.context ?? context)?.listMedia ??
          [];

  late final initialPage =
      listMedia.indexWhere((element) => element.key == widget.media.key);

  late final PageController pageController = PageController(
    initialPage: initialPage <= 0 ? 0 : initialPage,
  );

  final zoomController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool isZooming = false;

  @override
  void dispose() {
    pageController.dispose();
    zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DismissiblePage(
          onDismissed: () => Navigator.pop(context),
          disabled: isZooming,
          direction: DismissiblePageDismissDirection.vertical,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: listMedia.isEmpty
                ? interactiveViewer(widget.media.fullview)
                : PageView.builder(
                    physics:
                        isZooming ? const NeverScrollableScrollPhysics() : null,
                    controller: pageController,
                    itemCount: listMedia.length,
                    itemBuilder: (context, index) => interactiveViewer(
                      listMedia.elementAtOrNull(index)?.fullview,
                    ),
                  ),
          ),
        ),
        Positioned(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CloseButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget interactiveViewer(Widget? child) => child != null
      ? GestureDetector(
          onDoubleTapDown: (d) => _doubleTapDetails = d,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: zoomController,
            maxScale: 10,
            minScale: 1,
            child: Center(child: child),
            onInteractionEnd: (details) => _updateIsZooming(),
          ),
        )
      : const SizedBox();

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;
    final scale = zoomController.value.getMaxScaleOnAxis();
    late final Matrix4 targetMatrix;

    if (scale >= 4) {
      targetMatrix = Matrix4.identity();
    } else {
      final targetScale = scale * 3; // 3x

      final position = _doubleTapDetails!.localPosition;
      targetMatrix = Matrix4.identity()
        ..translate(
          -position.dx * (targetScale - 1),
          -position.dy * (targetScale - 1),
        )
        ..scale(targetScale);
    }

    final AnimationController animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: scale >= 4 ? 150 : 300),
    );

    final Animation<Matrix4> animation =
        Matrix4Tween(begin: zoomController.value, end: targetMatrix)
            .animate(animationController);

    animation.addListener(() {
      zoomController.value = animation.value;
      _updateIsZooming();
    });

    animationController.forward();
  }

  _updateIsZooming() => setState(
        () => isZooming = zoomController.value.getMaxScaleOnAxis() >= 1.1,
      );
}
