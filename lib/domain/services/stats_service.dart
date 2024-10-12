import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_model.dart';
import 'package:rewild_bot_front/presentation/products/all_subjects_screen/all_subjects_view_model.dart';

// Api Client
abstract class StatsServiceStatsApiClient {
  Future<Either<RewildError, List<SubjectModel>>> getAllSubjects(
      {required String token,
      required int take,
      required int skip,
      required List<int> subjectIds});
}

// subject Data provider
abstract class StatsServiceSubjectDataProvider {
  Future<Either<RewildError, void>> updateAll(List<SubjectModel> subjects);
  Future<Either<RewildError, SubjectModel?>> getOne(int subjectId);
}

// normquery Data provider

class StatsService implements AllSubjectsViewModelStatsService {
  final StatsServiceStatsApiClient statsApiClient;
  final StatsServiceSubjectDataProvider subjectDataProvider;

  StatsService({
    required this.statsApiClient,
    required this.subjectDataProvider,
  });

  @override
  Future<Either<RewildError, List<SubjectModel>>> getAllSubjects({
    required String token,
    required int take,
    required int skip,
    required List<int> subjectIds,
  }) async {
    // try to get from local storage
    // print('AAAAAAAAAA ${subjectIds}');
    List<SubjectModel> localySavedSubjects = [];
    List<int> missingSubjectIds = [];
    for (var subjectId in subjectIds) {
      final subjectEither = await subjectDataProvider.getOne(subjectId);
      final subjOrNull = subjectEither.fold((l) => null, (r) => r);
      if (subjOrNull != null && isToday(subjOrNull.updatedAt)) {
        localySavedSubjects.add(subjOrNull);
      } else {
        // print('subjOrNull adsfdsdsaz: ${subjOrNull!.updatedAt}');
        missingSubjectIds.add(subjectId);
      }
    }

    // get missed subjects
    final subjectsFromServerEither = await statsApiClient.getAllSubjects(
      token: token,
      take: take,
      skip: skip,
      subjectIds: missingSubjectIds,
    );

    if (subjectsFromServerEither.isLeft()) {
      return left(subjectsFromServerEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    final subjectsFromServer = subjectsFromServerEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    // update localy saved subjects
    await subjectDataProvider.updateAll(subjectsFromServer);

    final allSubjects = [...localySavedSubjects, ...subjectsFromServer];

    return right(allSubjects);
  }
}
