import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:reddit_2_reddit/components/show_profile_pic.dart';
import 'package:reddit_2_reddit/constants.dart';
import 'package:reddit_2_reddit/screens/reddit_auth_web_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

enum optionType { comments, subreddits, posts, redditors }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Reddit2Reddit',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'R2R - Reddit to Reddit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fromAccountState = '';
  String fromAccountImageLink =
      'https://styles.redditmedia.com/t5_3f0v8e/styles/profileIcon_snooaa919415-3025-4267-afce-11ac046bbd55-headshot-f.png?width=256&height=256&crop=256:256,smart&s=4d2da19933116332f11b411dfd3a875f5b93d5b5';
  String toAccountState = '';
  String toAccountImageLink = '';

  String errorText = '';
  bool transferButtonEnabled = true;

  Set optionSet = {
    optionType.comments,
    optionType.posts,
    optionType.redditors,
    optionType.subreddits
  };

  setAccountState({required String account, required String state}) {
    if (account == 'fromAccount') {
      fromAccountState = state;
    } else {
      toAccountState = state;
    }
    setState(() {});
  }

  setAccountImageLink({required String account, required String imageLink}) {
    if (account == 'fromAccount') {
      fromAccountImageLink = imageLink;
    } else {
      toAccountImageLink = imageLink;
    }
    setState(() {});
  }

  changeErrorText(String errortext) {
    setState(() {
      if (errortext == '') {
        errorText = '';
        transferButtonEnabled = true;
      } else {
        errorText = errortext;
        transferButtonEnabled = false;
      }
    });
  }

  editSet({required optionType option, required String action}) {
    if (action == 'add') {
      optionSet.add(option);
      if (optionSet.length == 1) {
        changeErrorText('');
      }
    } else {
      optionSet.remove(option);
      if (optionSet.isEmpty) {
        changeErrorText('Select atleast one of the transfer option!!');
      }
    }
  }

  Future<void> _transferConfirmationBox() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        List<AlertBoxPoints> optionList = [];
        for (final value in optionSet) {
          String text = '';
          if (value == optionType.comments) {
            text = "Saved Comments";
          } else if (value == optionType.posts) {
            text = "Saved Posts";
          } else if (value == optionType.subreddits) {
            text = "Following Subreddits";
          } else if (value == optionType.redditors) {
            text = "Following Redditors";
          }
          optionList.add(AlertBoxPoints(text: text));
        }

        return AlertDialog(
          title: const Text('Confirm you want to transfer :-'),
          titleTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
          elevation: 10,
          content: SingleChildScrollView(
            child: ListBody(
              children: optionList,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kRedditOrange,
        actions: const [Image(image: AssetImage('assets/icon/appicon.png'))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Column(
          children: [
            const Text('Tap to select account / Tap the account to log out'),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (fromAccountImageLink == '') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RedditAuthWebScreen(),
                        ),
                      );
                    } else {
                      // ask to remove token from server
                      setState(() {
                        fromAccountImageLink = '';
                        fromAccountState = '';
                      });
                      Fluttertoast.showToast(
                        msg: "Logged out",
                        backgroundColor: Colors.grey[400],
                        textColor: Colors.black,
                      );
                    }
                  },
                  child: fromAccountImageLink == ''
                      ? Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: const Center(
                            child: Text('From Account 1'),
                          ),
                        )
                      : ShowProfilePicture(url: fromAccountImageLink),
                ),
                const Icon(Icons.arrow_forward_rounded),
                GestureDetector(
                  onTap: () {
                    if (toAccountImageLink == '') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RedditAuthWebScreen(),
                        ),
                      );
                    } else {
                      // ask to remove token from server
                      setState(() {
                        toAccountImageLink = '';
                        toAccountState = '';
                      });
                    }
                  },
                  child: toAccountImageLink == ''
                      ? Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: const Center(
                            child: Text('To Account 2'),
                          ),
                        )
                      : ShowProfilePicture(url: toAccountImageLink),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Select options to transfer',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: 25.0,
              alignment: WrapAlignment.center,
              runSpacing: 5.0,
              children: [
                CheckboxOption(
                  label: 'Saved Comments',
                  editSetFunction: editSet,
                  optiontype: optionType.comments,
                ),
                CheckboxOption(
                  label: 'Joined Subreddits',
                  editSetFunction: editSet,
                  optiontype: optionType.subreddits,
                ),
                CheckboxOption(
                  label: 'Saved Posts',
                  editSetFunction: editSet,
                  optiontype: optionType.posts,
                ),
                CheckboxOption(
                  label: 'Following Redditors',
                  editSetFunction: editSet,
                  optiontype: optionType.redditors,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: transferButtonEnabled
                    ? () {
                        _transferConfirmationBox();
                      }
                    : null,
                child: const Text("Start Transfer"),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  primary: kRedditOrange,
                ),
              ),
            ),
            errorText == ''
                ? Container()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: const Center(
                  child: Text(
                      'Transfer process logs and stats will be shown here'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertBoxPoints extends StatelessWidget {
  const AlertBoxPoints({
    Key? key,
    required this.text,
  }) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.blur_on_rounded,
          size: 10,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text),
      ],
    );
  }
}

class CheckboxOption extends StatefulWidget {
  const CheckboxOption({
    Key? key,
    required this.label,
    required this.editSetFunction,
    required this.optiontype,
  }) : super(key: key);
  final String label;
  final Function editSetFunction;
  final optionType optiontype;

  @override
  State<CheckboxOption> createState() => _CheckboxOptionState();
}

class _CheckboxOptionState extends State<CheckboxOption> {
  bool checked = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            value: checked,
            onChanged: (value) {
              if (value!) {
                widget.editSetFunction(
                    option: widget.optiontype, action: 'add');
              } else {
                widget.editSetFunction(
                    option: widget.optiontype, action: 'dek');
              }
              setState(() {
                checked = !checked;
              });
            }),
        Text(
          widget.label,
          style: TextStyle(color: checked ? Colors.black : Colors.grey),
        ),
      ],
    );
  }
}
