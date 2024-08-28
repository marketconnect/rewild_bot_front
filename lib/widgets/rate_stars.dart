import 'package:flutter/material.dart';

class RateStars extends StatelessWidget {
  const RateStars({super.key, required this.valuation, this.starHeight});
  final int valuation;
  final double? starHeight;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.star,
            size: starHeight,
            color: const Color(0xFFf8d253),
          ),
          Icon(
            Icons.star,
            size: starHeight,
            color: valuation > 1
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            size: starHeight,
            color: valuation > 2
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            size: starHeight,
            color: valuation > 3
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            size: starHeight,
            color: valuation > 4
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
        ],
      ),
    );
  }
}
