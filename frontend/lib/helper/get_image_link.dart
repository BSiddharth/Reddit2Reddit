import 'package:http/http.dart' as http;
import 'package:reddit_2_reddit/constants.dart';

Future<http.Response> getImageLink({
  required String state,
}) async {
  Future<http.Response> response = http.post(
    Uri.parse(
      '$kUrl/profileImage/',
    ),
    body: {
      'state': state,
    },
  );
  return response;
}
