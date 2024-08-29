import 'package:flutter/material.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';

class EmptyApiKey extends StatelessWidget {
  const EmptyApiKey({super.key, required this.text, required this.route});
  final String text;
  final String route;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyWidget(
              text: text,
            ),
            const SizedBox(height: 20), // Небольшой отступ между виджетами
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(route),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: screenWidth * 0.7,
                height: screenHeight * 0.08,
                child: Text(
                  'Добавить токен',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
