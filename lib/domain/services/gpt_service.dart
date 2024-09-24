import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/presentation/gpt_screen/gpt_screen_view_model.dart';

abstract class GptServiceGptApiClient {
  // Future<Either<RewildError, int>> estimateTokens({
  //   required List<Map<String, String>> messages,
  // });
  Future<Either<RewildError, String>> chatCompletion({
    required String token,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    double topP = 0.9,
    int maxTokens = 150,
    int n = 1,
  });
}

class GptService implements GptScreenGptService {
  const GptService({required this.gptApiClient});
  final GptServiceGptApiClient gptApiClient;

  @override
  Future<Either<RewildError, String>> getAnswer(
      String token, List<Map<String, String>> messages) async {
    // estimate tokens
    // final estimateResultEither = await gptApiClient.estimateTokens(
    //   messages: [
    //     {'role': 'user', 'content': question},
    //   ],
    // );
    // if (estimateResultEither.isLeft()) {
    //   return left(estimateResultEither.fold(
    //       (l) => l, (r) => throw UnimplementedError()));
    // }

    // final estimateResult =
    //     estimateResultEither.fold((l) => throw UnimplementedError(), (r) => r);
    // print('estimateResult: $estimateResult');
    // final messages = [
    //   {'role': 'user', 'content': question},
    // ];
    return await gptApiClient.chatCompletion(
      token: token,
      messages: messages,
      temperature: 0.7,
      topP: 0.9,
      maxTokens: 150,
      n: 1,
    );
  }
}
