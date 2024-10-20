import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/commission_model.dart';
import 'package:rewild_bot_front/presentation/home/unit_economics_all_cards_screen/unit_economics_all_cards_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

abstract class CommissionServiceCommissionApiClient {
  Future<Either<RewildError, CommissionModel>> get(
      {required String token, required int id});
}

abstract class CommissionServiceCommissionDataProvider {
  Future<Either<RewildError, CommissionModel?>> get({required int id});
  Future<Either<RewildError, void>> insert(
      {required CommissionModel commission});
}

class CommissionService
    implements
        SingleCardScreenCommissionService,
        UnitEconomicsAllCardsCommissionService {
  final CommissionServiceCommissionApiClient commissionApiClient;
  final CommissionServiceCommissionDataProvider commissionDataProvider;

  CommissionService(
      {required this.commissionApiClient,
      required this.commissionDataProvider});

  @override
  Future<Either<RewildError, CommissionModel>> get(
      {required String token, required int id}) async {
    // get from local db
    final commissionEither = await commissionDataProvider.get(id: id);
    if (commissionEither.isLeft()) {
      return left(
          commissionEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final commission =
        commissionEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (commission == null) {
      // not found in local db
      // get from server
      final commissionFromServerEither =
          await commissionApiClient.get(token: token, id: id);
      return commissionFromServerEither.fold((l) => left(l), (commision) async {
        // save to local db
        final saveEither =
            await commissionDataProvider.insert(commission: commision);
        return saveEither.fold((l) => left(l), (r) {
          return right(commision);
        });
      });
    }
    return right(commission);
  }
}
