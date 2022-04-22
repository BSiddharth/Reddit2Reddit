import 'package:http/http.dart' as http;
import 'package:reddit_2_reddit/constants.dart';

Future<http.Response> deleteUser({
  required String state,
}) async {
  Future<http.Response> response = http.delete(
    Uri.parse(
      '$kUrl/deleteUser/',
    ),
    body: {
      'state': state,
    },
  );
  return response;
}
