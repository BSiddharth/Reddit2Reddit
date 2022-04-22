import 'package:http/http.dart' as http;
import 'package:reddit_2_reddit/constants.dart';

Future<http.Response> startTransfer(
    {required String fromState,
    required String toState,
    required Set<optionType> optionSet}) async {
  Future<http.Response> response = http.post(
    Uri.parse(
      '$kUrl/transfer/',
    ),
    body: {
      'fromState': fromState,
      'toState': toState,
      'comments': optionSet.contains(optionType.comments) ? 'true' : 'false',
      'posts': optionSet.contains(optionType.posts) ? 'true' : 'false',
      'redditors': optionSet.contains(optionType.redditors) ? 'true' : 'false',
      'subreddits':
          optionSet.contains(optionType.subreddits) ? 'true' : 'false',
    },
  );
  return response;
}
