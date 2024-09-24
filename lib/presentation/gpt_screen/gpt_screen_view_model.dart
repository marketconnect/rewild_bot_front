import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

abstract class GptScreenTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class GptScreenGptService {
  Future<Either<RewildError, String>> getAnswer(
      String token, List<Map<String, String>> messages);
}

class GptScreenViewModel extends ResourceChangeNotifier {
  GptScreenViewModel({
    required super.context,
    required this.gptService,
    required this.tokenService,
    required String questionText,
  }) : _questionText = questionText;

  // Constructor parameters
  final GptScreenGptService gptService;
  final GptScreenTokenService tokenService;
  final String _questionText;

  String get questionText => _questionText;

  //
  List<Map<String, String>> _messages = [];
  void addMessage(String value) {
    _messages.add({'role': 'user', 'content': value});
  }

  Future<String> getAnswer(String question) async {
    final tokenOrNull = await fetch(() => tokenService.getToken());
    if (tokenOrNull == null) {
      return "";
    }

    addMessage(question);
    print(_messages);
    final answerOrNull =
        await fetch(() => gptService.getAnswer(tokenOrNull, _messages));
    if (answerOrNull == null) {
      return "";
    }
    return answerOrNull;
  }
}
