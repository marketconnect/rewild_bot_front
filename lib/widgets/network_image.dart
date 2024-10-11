import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class ReWildNetworkImage extends StatelessWidget {
  const ReWildNetworkImage({
    super.key,
    this.width,
    this.height,
    this.errorImage,
    required this.image,
    this.fit,
  }) : assert(width != null || height != null);

  final double? width;
  final double? height;
  final String? errorImage;
  final BoxFit? fit;
  final String image;

  bool validateURL(String? input) {
    if (input == null) {
      return false;
    }
    if (Uri.tryParse(input)?.hasAbsolutePath ?? false) {
      return Uri.parse(input).host.isNotEmpty;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Если URL недействителен
    if (!validateURL(image)) {
      return GestureDetector(
        onTap: () {
          // Показываем SnackBar при нажатии
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Карточка не добавлена.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Image.asset(
          width: width,
          height: height,
          errorImage ?? ImageConstant.empty,
          fit: BoxFit.scaleDown,
        ),
      );
    }

    // Если URL действителен, показываем изображение с кэшем
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: image,
        placeholder: (context, url) => const MyProgressIndicator(),
        errorWidget: (context, url, error) => Image.asset(
          errorImage ?? ImageConstant.empty,
          fit: BoxFit.scaleDown,
        ),
        fit: fit ?? BoxFit.fill,
      ),
    );
  }
}
