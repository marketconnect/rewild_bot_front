import 'package:flutter/material.dart';

class LinkBtn extends StatelessWidget {
  const LinkBtn({
    super.key,
    required this.text,
    required this.route,
    this.iconData,
    required this.color,
    this.child,
  });

  final String text;

  final String route;
  final IconData? iconData;
  final Widget? child;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: child ??
                    Icon(
                      iconData,
                      color: Theme.of(context).colorScheme.surface,
                      size: screenWidth * 0.05,
                    ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
