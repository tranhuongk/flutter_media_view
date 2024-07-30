import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:media_view/media_view.dart';
import 'package:media_view/src/utils.dart';
import 'package:shimmer/shimmer.dart';

class ImageView extends MediaView {
  ImageView({
    Key? key,
    bool? ignoreFullView,
    super.onTap,
    super.context,
    required this.uri,
    super.aboveBuilder,
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.width,
    this.height,
    this.color,
    this.heroTag,
    this.cache = true,
    this.decoration,
    this.clipBehavior,
    this.margin,
    this.padding,
    this.errorBuilder,
    this.loadingBuilder,
  }) : super(
          key: key ?? Key(uri.toString()),
          ignoreFullView: ignoreFullView ?? (uri.isSvg || uri.fromAsset),
        );

  final Uri uri;
  final BoxFit fit;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final Color? color;
  final String? heroTag;
  final bool cache;
  final Decoration? decoration;
  final Clip? clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder;

  @override
  Widget get child => Hero(
        tag: heroTag ?? key.toString(),
        child: _ImageView(
          uri: uri,
          fit: fit,
          aspectRatio: aspectRatio,
          width: width,
          height: height,
          color: color,
          cache: cache,
          decoration: decoration,
          clipBehavior: clipBehavior,
          errorBuilder: errorBuilder,
          margin: margin,
          padding: padding,
          loadingBuilder: loadingBuilder,
        ),
      );

  @override
  Widget get fullView => Hero(
        tag: heroTag ?? key.toString(),
        child: _FullImageView(
          uri: uri,
          color: color,
          cache: cache,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        ),
      );
}

sealed class _SealedImageView extends StatelessWidget {
  const _SealedImageView({
    required this.uri,
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.width,
    this.height,
    this.color,
    this.cache = true,
    this.decoration,
    this.clipBehavior,
    this.margin,
    this.padding,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final Uri uri;
  final BoxFit fit;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final Color? color;
  final bool cache;
  final Decoration? decoration;
  final Clip? clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    final imageChild = switch (uri) {
      _ when uri.fromFileSvg => fileSvg,
      _ when uri.fromFile => file,
      _ when uri.fromAssetSvg => assetSvg,
      _ when uri.fromAsset => asset(),
      _ when uri.fromNetworkSvg => networkSvg,
      _ when uri.fromNetwork => network,
      _ => const SizedBox(),
    };

    final aspectRatioChild = aspectRatio != null
        ? AspectRatio(aspectRatio: aspectRatio!, child: imageChild)
        : imageChild;

    return Container(
      width: width,
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      clipBehavior:
          clipBehavior ?? (decoration != null ? Clip.hardEdge : Clip.none),
      child: aspectRatioChild,
    );
  }

  Widget get errorWidget =>
      asset('packages/media_view/assets/img_no_image.png');
  Widget get loadingWidget => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: const ColoredBox(color: Colors.white),
      );

  Widget get network => cache
      ? CachedNetworkImage(
          imageUrl: uri.toString(),
          fit: fit,
          color: color,
          errorWidget: (context, url, error) =>
              errorBuilder?.call(context, error) ?? errorWidget,
          progressIndicatorBuilder: (context, url, progress) =>
              loadingBuilder?.call(
                context,
                ImageChunkEvent(
                  expectedTotalBytes: progress.totalSize,
                  cumulativeBytesLoaded: progress.downloaded,
                ),
              ) ??
              loadingWidget,
        )
      : Image.network(
          uri.toString(),
          fit: fit,
          color: color,
          semanticLabel: uri.pathSegments.lastOrNull,
          errorBuilder: (context, error, stackTrace) =>
              errorBuilder?.call(context, error) ?? errorWidget,
          loadingBuilder: (context, child, loadingProgress) =>
              loadingBuilder?.call(context, loadingProgress) ?? loadingWidget,
        );

  Widget get networkSvg => SvgPicture.network(
        uri.toString(),
        fit: fit,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (context) => loadingWidget,
      );

  Widget asset([String? path]) => Image.asset(
        path ?? uri.toString(),
        fit: fit,
        semanticLabel: uri.pathSegments.lastOrNull,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            errorBuilder?.call(context, error) ?? errorWidget,
      );

  Widget get assetSvg => SvgPicture.asset(
        uri.toString(),
        fit: fit,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        semanticsLabel: uri.pathSegments.lastOrNull,
        placeholderBuilder: (context) => loadingWidget,
      );

  Widget get file => Image.file(
        File(uri.toString()),
        fit: fit,
        semanticLabel: uri.pathSegments.lastOrNull,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            errorBuilder?.call(context, error) ?? errorWidget,
      );

  Widget get fileSvg => SvgPicture.file(
        File(uri.toString()),
        fit: fit,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (context) => loadingWidget,
      );
}

class _ImageView extends _SealedImageView {
  const _ImageView({
    required super.uri,
    super.fit,
    super.aspectRatio,
    super.height,
    super.width,
    super.color,
    super.cache,
    super.decoration,
    super.clipBehavior,
    super.margin,
    super.padding,
    super.errorBuilder,
    super.loadingBuilder,
  });
}

class _FullImageView extends _SealedImageView {
  const _FullImageView({
    required super.uri,
    super.color,
    super.cache,
    super.errorBuilder,
    super.loadingBuilder,
  });
}
