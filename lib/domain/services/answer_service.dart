import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/presentation/feedback/questions/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_reviews_screen/all_reviews_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';

abstract class AnswerServiceAnswerDataProvider {
  Future<Either<RewildError, bool>> delete(
      {required String id, required String type});
  Future<Either<RewildError, bool>> insert(
      {required String id, required String answer, required String type});
  Future<Either<RewildError, List<String>>> getAllIds({required String type});
  Future<Either<RewildError, List<String>>> getAll({required String type});
}

class AnswerService
    implements
        AllQuestionsViewModelAnswerService,
        SingleReviewViewModelAnswerService,
        AllReviewsViewModelAnswerService,
        SingleQuestionViewModelAnswerService {
  final AnswerServiceAnswerDataProvider answerDataProvider;
  const AnswerService({required this.answerDataProvider});

  @override
  Future<Either<RewildError, bool>> deleteQuestion({
    required String questionId,
  }) async {
    return await answerDataProvider.delete(id: questionId, type: 'question');
  }

  @override
  Future<Either<RewildError, bool>> deleteReview({
    required String reviewId,
  }) async {
    return await answerDataProvider.delete(id: reviewId, type: 'review');
  }

  @override
  Future<Either<RewildError, bool>> insertQuestion(
      {required String questionId, required String answer}) async {
    return await answerDataProvider.insert(
        id: questionId, answer: answer, type: 'question');
  }

  @override
  Future<Either<RewildError, bool>> insertReview(
      {required String reviewId, required String answer}) async {
    return await answerDataProvider.insert(
        id: reviewId, answer: answer, type: 'review');
  }

  @override
  Future<Either<RewildError, List<String>>> getAllQuestions() async {
    return await answerDataProvider.getAll(type: 'question');
  }

  @override
  Future<Either<RewildError, List<String>>> getAllReviews() async {
    return await answerDataProvider.getAll(type: 'review');
  }

  @override
  Future<Either<RewildError, List<String>>> getAllQuestionIds() async {
    return await answerDataProvider.getAllIds(type: 'question');
  }

  @override
  Future<Either<RewildError, List<String>>> getAllReviewIds() async {
    return await answerDataProvider.getAllIds(type: 'review');
  }
}
