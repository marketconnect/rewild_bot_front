import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/warehouse.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/warehouse_service.dart';

class WarehouseApiClient
    implements
        CardOfProductServiceWarehouseApiCient,
        WarehouseServiceWerehouseApiClient
// WarehouseServiceWerehouseApiClient
{
  const WarehouseApiClient();
  @override
  Future<Either<RewildError, List<Warehouse>>> getAll() async {
    try {
      final uri = Uri.parse('https://rewild.website/api/warehouse/');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final warehouses = data['value']['times'];
        List<Warehouse> resultWarehousesList = [];

        for (final warehouse in warehouses) {
          Warehouse w = Warehouse.fromJson(warehouse);
          resultWarehousesList.add(w);
        }

        return right(resultWarehousesList);
      } else {
        return left(RewildError(
          sendToTg: false,
          'Error ${response.statusCode}',
          source: "WarehouseApiClient",
          name: "getAll",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "$e",
        source: "WarehouseApiClient",
        name: "getAll",
        args: [],
      ));
    }
  }
}
