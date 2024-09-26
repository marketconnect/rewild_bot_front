import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for Clipboard
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/presentation/gpt_screen/gpt_screen_view_model.dart';

class ChatGptScreen extends StatefulWidget {
  const ChatGptScreen({super.key});

  @override

  // ignore: library_private_types_in_public_api
  _ChatGptScreenState createState() => _ChatGptScreenState();
}

class _ChatGptScreenState extends State<ChatGptScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_Message> _messages = [];

  @override
  void initState() {
    super.initState();
    final initMessage = context.read<GptScreenViewModel>().questionText;
    _messageController.text = initMessage;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _messageController.clear();
    });

    final model = context.read<GptScreenViewModel>();
    final getAnswer = model.getAnswer;

    // Show typing indicator
    setState(() {
      _messages
          .add(_Message(text: '...', isUser: false, isTypingIndicator: true));
    });

    final answer = await getAnswer(text);

    // Remove typing indicator and add actual response
    setState(() {
      _messages.removeLast(); // Remove typing indicator
      _messages.add(_Message(text: answer, isUser: false));
    });
  }

  Widget _buildMessageItem(_Message message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Stack(
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16.0,
                ),
              ),
            ),
            // Copy icon for bot messages
            if (!message.isUser && !message.isTypingIndicator)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.content_copy,
                      size: 16.0, color: Colors.grey[600]),
                  onPressed: () {
                    // Copy bot message to clipboard
                    Clipboard.setData(ClipboardData(text: message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Сообщение скопировано в буфер обмена.')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - index - 1];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12, offset: Offset(0, -1), blurRadius: 4.0),
        ]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Введите ваше сообщение...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isTypingIndicator;

  _Message(
      {required this.text,
      required this.isUser,
      this.isTypingIndicator = false});
}
