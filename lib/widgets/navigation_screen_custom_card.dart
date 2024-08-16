import 'package:flutter/material.dart';

class NavigationScreenCustomCard extends StatelessWidget {
  const NavigationScreenCustomCard({
    super.key,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.title,
    required this.context,
  });
  final IconData icon;
  final void Function()? onTap;
  final Color backgroundColor;
  final String title;
  final BuildContext context;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.05),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.width * 0.05),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFececec),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(Icons.arrow_forward_ios_outlined,
                        size: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
