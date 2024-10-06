import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';
import 'package:rewild_bot_front/env.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackFormScreenState createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _feedbackController = TextEditingController();
  bool _isSending = false;

  void _sendFeedback() async {
    final feedbackText = _feedbackController.text;
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ваше сообщение.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final id = await TelegramWebApp.getChatId();
      final messageToSend = 'id:$id $feedbackText';
      await sendMessageToTelegramBot(
        TBot.tBotFeedbackToken,
        TBot.tBotFeedbackChatId,
        messageToSend,
      );

      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Спасибо за вашу обратную связь!')),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Не удалось отправить сообщение. Повторите позже.')),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Обратная связь'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Мы ценим ваше мнение. Пожалуйста, поделитесь своими идеями или сообщите об ошибках.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Поле для ввода обратной связи
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Введите ваше сообщение здесь',
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              // Кастомная кнопка отправки
              CustomElevatedButton(
                onTap: _isSending ? null : _sendFeedback,
                text: _isSending ? 'Отправка...' : 'Отправить',
                buttonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                height: screenHeight * 0.07,
              ),
              const SizedBox(height: 16),
              if (_isSending)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
