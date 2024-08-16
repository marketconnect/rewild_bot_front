import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

Future<Either<RewildError, String>> generateContentHash(String url) async {
  final bytesOrNull = await _fetchFileBytes(url);
  if (bytesOrNull.isLeft()) {
    return left(bytesOrNull.fold((l) => l, (r) => throw UnimplementedError()));
  }
  final bytes = bytesOrNull.fold((l) => throw UnimplementedError(), (r) => r);
  final hash = sha256.convert(bytes);
  return right(hash.toString());
}

Future<Either<RewildError, List<int>>> _fetchFileBytes(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return right(response.bodyBytes);
    } else {
      return left(RewildError(
        response.body,
        name: "fetchFileBytes",
        source: '_fetchFileBytes',
        sendToTg: true,
        args: [],
      ));
    }
  } catch (e) {
    return left(RewildError(
      e.toString(),
      name: "fetchFileBytes",
      source: '_fetchFileBytes',
      sendToTg: true,
      args: [],
    ));
  }
}
