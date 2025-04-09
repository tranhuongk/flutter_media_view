import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_view/media_view.dart';

class FullMediaView extends StatefulWidget {
  const FullMediaView({
    required this.media,
    required this.aboveBuilder,
    super.key,
  });

  final MediaView media;
  final Function(MediaView index)? aboveBuilder;

  static void openFullView(
    BuildContext context,
    MediaView media,
    Widget Function(MediaView index)? aboveBuilder,
  ) {
    if (media.ignoreFullView) return;

    (media.context ?? context).pushTransparentRoute(FullMediaView(
      media: media,
      aboveBuilder: aboveBuilder,
    ));
  }

  @override
  State<FullMediaView> createState() => _FullMediaViewState();
}

class _FullMediaViewState extends State<FullMediaView>
    with TickerProviderStateMixin {
  late final List<MediaView> listMedia =
      MediaViewWrapper.maybeOf(widget.media.context ?? context)?.listMedia ??
          [];
  Widget Function(int)? get aboveBuilder =>
      MediaViewWrapper.maybeOf(widget.media.context ?? context)?.aboveBuilder;

  late final initialPage =
      listMedia.indexWhere((element) => element.key == widget.media.key);
  late int index = initialPage;

  late final PageController pageController = PageController(
    initialPage: initialPage <= 0 ? 0 : initialPage,
  );

  final zoomController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool isZooming = false;
  
  @override
  void initState() {
    super.initState();
    setFullScreen(true);
  }

  @override
  void dispose() {
    pageController.dispose();
    zoomController.dispose();
    setFullScreen(false);
    super.dispose();
  }

  void setFullScreen(bool isFullScreen) => SystemChrome.setEnabledSystemUIMode(
        isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );

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
                ? interactiveViewer(widget.media)
                : PageView.builder(
                    physics:
                        isZooming ? const NeverScrollableScrollPhysics() : null,
                    controller: pageController,
                    itemCount: listMedia.length,
                    onPageChanged: (i) => setState(() => index = i),
                    itemBuilder: (context, index) =>
                        interactiveViewer(listMedia.elementAtOrNull(index)),
                  ),
          ),
        ),
        if (aboveBuilder != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: aboveBuilder!(index),
          )
        else ...[
          Positioned(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CloseButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.black45)),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (listMedia.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: DefaultTextStyle(
                      style: (Theme.of(context).textTheme.labelLarge ??
                              const TextStyle(fontSize: 16))
                          .copyWith(color: Colors.white),
                      child: Text('${index + 1}/${listMedia.length}'),
                    ),
                  ),
                ),
              ),
            )
        ]
      ],
    );
  }

  Widget interactiveViewer(MediaView? child) => child != null
      ? Stack(
          children: [
            GestureDetector(
              onDoubleTapDown: (d) => _doubleTapDetails = d,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: zoomController,
                maxScale: 10,
                minScale: 1,
                child: Center(child: child.fullView),
                onInteractionEnd: (details) => _updateIsZooming(),
              ),
            ),
            if (child.aboveBuilder != null)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: child.aboveBuilder!(child),
              )
          ],
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
