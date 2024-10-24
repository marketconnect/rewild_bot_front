import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_commission_model.dart';
import 'package:rewild_bot_front/presentation/products/all_categories_screen/all_categories_view_model.dart';
import 'package:rewild_bot_front/presentation/products/all_subjects_screen/all_subjects_view_model.dart';

abstract class CategoriesAndSubjectsServiceApiClient {
  Future<Either<RewildError, List<String>>> getAllCategories({
    required String token,
  });
  Future<Either<RewildError, List<SubjectCommissionModel>>> getSubjects(
      {required String token, required List<String> catNames});
}

// Categories Data Provider
abstract class CategoriesAndSubjectsServiceCategoriesDataProvider {
  Future<Either<RewildError, void>> updateAll(List<String> categories);
  Future<Either<RewildError, bool>> isUpdated();
  Future<Either<RewildError, List<String>>> getAllCategories();
}

// Subjects Data Provider
abstract class CategoriesAndSubjectsServiceSubjectsDataProvider {
  Future<Either<RewildError, bool>> isUpdated(String catName);
  Future<Either<RewildError, List<SubjectCommissionModel>>> getAllForCatName(
      String catName);
  Future<Either<RewildError, void>> insertAll(
    List<SubjectCommissionModel> models,
  );
}

class CategoriesAndSubjectsService
    implements
        AllSubjectsViewModelCatAndSubjService,
        AllCategoriesScreenCategoriesService {
  final CategoriesAndSubjectsServiceApiClient categoriesAndSubjectsApiClien;
  final CategoriesAndSubjectsServiceCategoriesDataProvider
      categoriesDataProvider;
  final CategoriesAndSubjectsServiceSubjectsDataProvider catAndSubjDataProvider;

  const CategoriesAndSubjectsService(
      {required this.categoriesAndSubjectsApiClien,
      required this.catAndSubjDataProvider,
      required this.categoriesDataProvider});

  @override
  Future<Either<RewildError, List<String>>> getAll({
    required String token,
  }) async {
    // Try to get categories from cache
    // check if categories were updated today
    final updatedOrEither = await categoriesDataProvider.isUpdated();
    if (updatedOrEither.isRight()) {
      final isUpdated =
          updatedOrEither.fold((l) => throw UnimplementedError(), (r) => r);
      // if categories were updated return them
      if (isUpdated) {
        final cacheOrEither = await categoriesDataProvider.getAllCategories();
        if (cacheOrEither.isRight()) {
          final cache =
              cacheOrEither.fold((l) => throw UnimplementedError(), (r) => r);
          return right(cache);
        }
      }
    }
    // if categories were not updated
    // fetch them from api
    final resultOrEither =
        await categoriesAndSubjectsApiClien.getAllCategories(token: token);
    // update cache
    if (resultOrEither.isRight()) {
      final result =
          resultOrEither.fold((l) => throw UnimplementedError(), (r) => r);
      await categoriesDataProvider.updateAll(result);
    }
    return resultOrEither;
  }

  @override
  Future<Either<RewildError, List<SubjectCommissionModel>>> getCatSubjects(
      {required String token, required List<String> catNames}) async {
    // Try to get subjects from cache

    List<SubjectCommissionModel> localySavedSubjects = [];
    List<String> missingCatNames = [];
    for (var catName in catNames) {
      if (catName == "Все") {
        continue;
      }
      final isUpdatedEither = await catAndSubjDataProvider.isUpdated(catName);
      final isUpdatedOrNull = isUpdatedEither.fold((l) => null, (r) => r);
      if (isUpdatedOrNull != null && isUpdatedOrNull) {
        final subjEither =
            await catAndSubjDataProvider.getAllForCatName(catName);
        if (subjEither.isRight()) {
          final subjects =
              subjEither.fold((l) => throw UnimplementedError(), (r) => r);
          localySavedSubjects.addAll(subjects);
          continue;
        }
      } else {
        missingCatNames.add(catName);
      }
    }
    // get missed subjects
    final resultOrEither = await categoriesAndSubjectsApiClien.getSubjects(
        token: token, catNames: missingCatNames);

    // update cache
    if (resultOrEither.isRight()) {
      final result =
          resultOrEither.fold((l) => throw UnimplementedError(), (r) => r);
      await catAndSubjDataProvider.insertAll(result);
      localySavedSubjects.addAll(result);
    }

    return right(localySavedSubjects);
  }
}
