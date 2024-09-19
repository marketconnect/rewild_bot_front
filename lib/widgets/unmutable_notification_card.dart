import 'package:flutter/material.dart';

class UnmutableNotificationCard extends StatelessWidget {
  const UnmutableNotificationCard({
    super.key,
    required this.condition,
    required this.text,
    this.currentValue,
    this.suffix,
    this.topBorder = false,
    required this.isActive,
    required this.dropNotification,
    required this.addNotification,
  });

  final String condition;
  final bool isActive;
  final bool topBorder;
  final String? currentValue;
  final String? suffix;
  final String text;
  final Function(String condition) dropNotification;
  final Function(String condition, num? value) addNotification;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight * 0.11,
      decoration: BoxDecoration(
        border: topBorder
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ),
                top: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ))
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.15,
            child: IconButton(
              onPressed: () {
                if (!isActive) {
                  currentValue == null
                      ? addNotification(condition, null)
                      : addNotification(
                          condition,
                          int.tryParse(currentValue!) ??
                              double.tryParse(currentValue!));
                  return;
                }
                dropNotification(condition);
              },
              icon: Icon(
                Icons.notifications,
                color: !isActive
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.07,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.8),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "$currentValue${suffix ?? ""}",
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
