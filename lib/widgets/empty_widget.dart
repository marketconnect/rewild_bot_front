import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.text,
    this.img,
  });

  final String? text;
  final String? img;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          img ?? ImageConstant.imgNotFound,
          height: screenHeight * 0.2,
          width: screenWidth * 0.5,
        ),
        if (text != null)
          SizedBox(
            height: screenHeight * 0.02,
          ),
        if (text != null)
          SizedBox(
            width: screenWidth * 0.8,
            child: Text(
              text!,
              maxLines: 4,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ));
  }
}
