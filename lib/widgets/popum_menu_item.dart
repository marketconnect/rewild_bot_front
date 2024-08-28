import 'package:flutter/material.dart';

class ReWildPopumMenuItemChild extends StatelessWidget {
  const ReWildPopumMenuItemChild({
    super.key,
    required this.text,
    this.iconData,
    this.child,
  }) : assert(iconData != null || child != null);

  final IconData? iconData;
  final String text;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        child != null
            ? child!
            : Icon(
                iconData,
              ),
        const SizedBox(
          width: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
