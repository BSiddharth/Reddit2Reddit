import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RedditAuthWebScreen extends StatefulWidget {
  const RedditAuthWebScreen({
    Key? key,
    // required this.controller,
  }) : super(key: key);
  // final Completer<WebViewController> controller;

  @override
  State<RedditAuthWebScreen> createState() => _RedditAuthWebScreenState();
}

class _RedditAuthWebScreenState extends State<RedditAuthWebScreen> {
  var loadingPercentage = 0;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
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
                    'https://www.reddit.com//api/v1/authorize.compact?client_id=k4LGQvzExYaBGOcYTqdkNQ&response_type=code&state=abhikeliyekuchbhirandom&redirect_uri=http://192.168.1.52:5000/reddit-redirect/&duration=temporary&scope=identity')),
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
            onLoadStop: (controller, url) {
              setState(() {
                loadingPercentage = 100;
              });
              if (url
                  .toString()
                  .startsWith('http://192.168.1.52:5000/reddit-redirect')) {
                // do something
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
