import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:reddit_2_reddit/constants.dart';
import 'package:reddit_2_reddit/helper/get_image_link.dart';
import 'package:reddit_2_reddit/helper/get_stats.dart';

class RedditAuthWebScreen extends StatefulWidget {
  const RedditAuthWebScreen({
    Key? key,
    required this.state,
    required this.onLoadFunction,
    required this.changeStatFunction,
    required this.account,
  }) : super(key: key);
  final String state;
  final String account;
  final Function onLoadFunction;
  final Function changeStatFunction;

  @override
  State<RedditAuthWebScreen> createState() => _RedditAuthWebScreenState();
}

class _RedditAuthWebScreenState extends State<RedditAuthWebScreen> {
  var loadingPercentage = 0;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        cacheEnabled: false,
        clearCache: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialOptions: options,
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'https://www.reddit.com//api/v1/authorize.compact?client_id=k4LGQvzExYaBGOcYTqdkNQ&response_type=code&state=${widget.state}&redirect_uri=http://192.168.1.52:5000/reddit-redirect/&duration=permanent&scope=identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread')),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                loadingPercentage = 100;
              });
              if (url.toString().startsWith('$kUrl/reddit-redirect')) {
                final response = await getImageLink(state: widget.state);
                final String imageLink = jsonDecode(response.body)['img_link'];
                widget.onLoadFunction(
                    account: widget.account, imageLink: imageLink);
                if (widget.account == 'fromAccount') {
                  final response = await getStats(state: widget.state);
                  final data = jsonDecode(response.body);
                  widget.changeStatFunction(
                    c: data["comments"],
                    p: data["posts"],
                    s: data["subreddits"],
                    f: data["following"],
                  );
                }

                Navigator.pop(context);
              }
            },
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
