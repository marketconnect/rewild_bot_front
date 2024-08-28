import 'package:flutter/material.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class ReWildExpandableImage extends StatelessWidget {
  const ReWildExpandableImage({
    super.key,
    this.width,
    this.height,
    required this.expandedImagePath,
    this.colapsedImagePath,
  }) : assert(width != null || height != null);

  final double? width;
  final double? height;
  final String expandedImagePath;
  final String? colapsedImagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Hero(
                tag: 'imageHero$expandedImagePath',
                child: Image.network(expandedImagePath),
              ),
            );
          },
        );
      },
      child: Hero(
        tag: 'imageHero${colapsedImagePath ?? expandedImagePath}',
        child: ReWildNetworkImage(
          width: width,
          height: height,
          image: colapsedImagePath ?? expandedImagePath,
        ),
      ),
    );
  }
}
