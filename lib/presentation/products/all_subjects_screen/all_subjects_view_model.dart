import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_commission_model.dart';
import 'package:rewild_bot_front/domain/entities/subject_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class AllSubjectsViewModelStatsService {
  Future<Either<RewildError, List<SubjectModel>>> getAllSubjects({
    required String token,
    required int take,
    required int skip,
    required List<int> subjectIds,
  });
}

abstract class AllSubjectsViewModelCatAndSubjService {
  Future<Either<RewildError, List<SubjectCommissionModel>>> getCatSubjects(
      {required String token, required List<String> catNames});
}

// Token
abstract class AllSubjectsViewModelAuthService {
  Future<Either<RewildError, String>> getToken();
}

class AllSubjectsViewModel extends ResourceChangeNotifier {
  final List<String> catNames;
  final AllSubjectsViewModelStatsService statsService;
  final AllSubjectsViewModelAuthService authService;
  final AllSubjectsViewModelCatAndSubjService catAndSubjService;
  AllSubjectsViewModel(
      {required super.context,
      required this.catNames,
      required this.catAndSubjService,
      required this.statsService,
      required this.authService}) {
    _asyncInit();
  }

  _asyncInit() async {
    // SqfliteService.printTableContent('subject_commissions');
    setIsLoading(true);
    // get token
    final tokenOrNull = await fetch(() => authService.getToken());
    if (tokenOrNull == null) {
      _subjects = [];
      notify();
      return;
    }

    // fetch subjects ids and commissions

    final subjectsIdsOrNull =
        await fetch(() => catAndSubjService.getCatSubjects(
              token: tokenOrNull,
              catNames: catNames,
            ));
    if (subjectsIdsOrNull == null) {
      _subjects = [];
      notify();
      return;
    }
    setSubjectCommissions(subjectsIdsOrNull);

    final subjectsIds = subjectsIdsOrNull.map((e) => e.id).toList();
    final subjectsOrNull = await fetch(() => statsService.getAllSubjects(
          token: tokenOrNull,
          take: 100000,
          skip: 0,
          subjectIds: subjectsIds,
        ));
    if (subjectsOrNull != null) {
      // print('length of subjects: ${subjectsOrNull.length}');
      setSubjects(subjectsOrNull);
    }
    setIsLoading(false);
  }

  // isLoading
  bool _isLoading = false;
  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  bool get isLoading => _isLoading;

  // Loading text
  String _loadingText = 'Получаю предметы и коммиссии...';
  void setLoadingText(String loadingText) {
    _loadingText = loadingText;
    notify();
  }

  String get loadingText => _loadingText;

  // Subjects
  List<SubjectModel> _subjects = [];
  void setSubjects(List<SubjectModel> subjects) {
    _subjects = subjects;
  }

  List<SubjectModel> get subjects => _subjects;

  // SubjectCommissions
  List<SubjectCommissionModel> _subjectCommissions = [];
  void setSubjectCommissions(List<SubjectCommissionModel> subjectCommissions) {
    _subjectCommissions = subjectCommissions;
  }

  SubjectCommissionModel getCommission(int subjectId) {
    final commissions = _subjectCommissions
        .where((element) => element.id == subjectId)
        .toList();
    if (commissions.isEmpty) {
      return SubjectCommissionModel(
        id: subjectId,
        catName: '',
        commission: 0,
        isKiz: false,
      );
    } else {
      return commissions.first;
    }
  }

  void sortSubjects(String criteria) {
    switch (criteria) {
      case 'percentageSkusWithoutOrdersAsc':
        _subjects.sort((a, b) => a.percentageSkusWithoutOrders
            .compareTo(b.percentageSkusWithoutOrders));
        break;
      case 'totalVolumeDesc':
        _subjects.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
        break;
      case 'totalRevenueDesc':
        _subjects.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      case 'totalSkusDesc':
        _subjects.sort((a, b) => b.totalSkus.compareTo(a.totalSkus));

      case 'totalOrdersDesc':
        _subjects.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
        break;

      case 'averageCheck':
        _subjects.sort((a, b) {
          final aAvgCheck = a.averageCheck();
          final bAvgCheck = b.averageCheck();
          return bAvgCheck.compareTo(aAvgCheck);
        });
        break;

      case 'conversionToOrdersDesc':
        _subjects.sort((a, b) {
          double aC = (a.totalOrders / a.totalVolume) * 100;
          double bC = (b.totalOrders / b.totalVolume) * 100;
          if (aC > 100) {
            aC = 0;
          }
          if (bC > 100) {
            bC = 0;
          }
          return bC.compareTo(aC);
        });
        break;
      case 'alphabeticalAsc':
        _subjects.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    notifyListeners();
  }

  void goToSubject(int subjectId, String subjectName) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.topProductsScreen,
      arguments: (subjectId, subjectName),
    );
  }
}
