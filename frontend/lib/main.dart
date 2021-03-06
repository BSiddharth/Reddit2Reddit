import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:random_string/random_string.dart';
import 'package:reddit_2_reddit/components/flutter_toast.dart';
import 'package:reddit_2_reddit/components/show_profile_pic.dart';
import 'package:reddit_2_reddit/constants.dart';
import 'package:reddit_2_reddit/helper/delete_user.dart';
import 'package:reddit_2_reddit/helper/start_transfer.dart';
import 'package:reddit_2_reddit/screens/reddit_auth_web_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

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

  String fromAccountImageLink = '';

  String toAccountState = '';

  String toAccountImageLink = '';

  String errorText = '';

  String comments = '0';
  String posts = '0';
  String subreddits = '0';
  String following = '0';

  bool transferButtonEnabled = false;

  Set<optionType> optionSet = {
    optionType.comments,
    optionType.posts,
    optionType.redditors,
    optionType.subreddits
  };

  setStatBox({
    required String c,
    required String p,
    required String s,
    required String f,
  }) {
    comments = c;
    posts = p;
    subreddits = s;
    following = f;
    setState(() {});
  }

  setAccountImageLink({required String account, required String imageLink}) {
    if (account == 'fromAccount') {
      fromAccountImageLink = imageLink;
    } else {
      toAccountImageLink = imageLink;
    }
    if (fromAccountImageLink != '' &&
        toAccountImageLink != '' &&
        optionSet.isNotEmpty) {
      transferButtonEnabled = true;
    }
    setState(() {});
  }

  setAccountState({required String account, required String state}) {
    if (account == 'fromAccount') {
      fromAccountState = state;
    } else {
      toAccountState = state;
    }
    setState(() {});
  }

  resetStatBox() {
    comments = '0';
    posts = '0';
    subreddits = '0';
    following = '0';
    setState(() {});
  }

  resetFunction({required String account}) {
    if (account == 'fromAccount') {
      fromAccountImageLink = '';
      fromAccountState = '';
    } else {
      toAccountImageLink = '';
      toAccountState = '';
    }
    transferButtonEnabled = false;
    setState(() {});
  }

  changeErrorText(String errortext) {
    setState(() {
      if (errortext == '') {
        errorText = '';
        if (fromAccountImageLink != '' &&
            toAccountImageLink != '' &&
            optionSet.isNotEmpty) {
          transferButtonEnabled = true;
        }
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
                startTransfer(
                        fromState: fromAccountState,
                        toState: toAccountState,
                        optionSet: optionSet)
                    .whenComplete(() =>
                        {showFlutterToast(stringLabel: "Transfer completed")});
                showFlutterToast(stringLabel: "Transfer Started");

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
                RedditProfileWidget(
                  accountImageLink: fromAccountImageLink,
                  holderString: 'From Account 1',
                  account: 'fromAccount',
                  setAccountStateFunction: setAccountState,
                  onLoadFunction: setAccountImageLink,
                  resetFunction: resetFunction,
                  accountState: fromAccountState,
                  changeStatFunction: setStatBox,
                  resetStatBoxFunction: resetStatBox,
                ),
                const Icon(Icons.arrow_forward_rounded),
                RedditProfileWidget(
                  accountImageLink: toAccountImageLink,
                  holderString: 'To Account 2',
                  account: 'toAccount',
                  setAccountStateFunction: setAccountState,
                  onLoadFunction: setAccountImageLink,
                  resetFunction: resetFunction,
                  accountState: toAccountState,
                  changeStatFunction: setStatBox,
                  resetStatBoxFunction: resetStatBox,
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
              child: StatBox(
                savedComments: comments,
                savedPosts: posts,
                following: following,
                subreddits: subreddits,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  const StatBox({
    Key? key,
    required this.savedComments,
    required this.subreddits,
    required this.following,
    required this.savedPosts,
  }) : super(key: key);
  final String savedComments;
  final String subreddits;
  final String following;
  final String savedPosts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatBoxColumn(
                data: savedPosts,
                label: 'Saved Posts',
              ),
              StatBoxColumn(
                data: subreddits,
                label: 'Subreddits',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatBoxColumn(
                data: following,
                label: 'Following',
              ),
              StatBoxColumn(
                data: savedComments,
                label: 'Saved comments',
              ),
            ],
          )
        ],
      )),
    );
  }
}

class StatBoxColumn extends StatelessWidget {
  const StatBoxColumn({Key? key, required this.label, required this.data})
      : super(key: key);
  final String data;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        )
      ],
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

class RedditProfileWidget extends StatelessWidget {
  const RedditProfileWidget({
    Key? key,
    required this.accountImageLink,
    required this.accountState,
    required this.holderString,
    required this.account,
    required this.setAccountStateFunction,
    required this.onLoadFunction,
    required this.resetFunction,
    required this.changeStatFunction,
    required this.resetStatBoxFunction,
  }) : super(key: key);
  final String accountImageLink;
  final String accountState;
  final String holderString;
  final String account;
  final Function setAccountStateFunction;
  final Function onLoadFunction;
  final Function resetFunction;
  final Function changeStatFunction;
  final Function resetStatBoxFunction;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (accountImageLink == '') {
          final accountState = randomAlphaNumeric(10);
          setAccountStateFunction(state: accountState, account: account);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RedditAuthWebScreen(
                state: accountState,
                onLoadFunction: onLoadFunction,
                account: account,
                changeStatFunction: changeStatFunction,
              ),
            ),
          );
        } else {
          if (account == 'fromAccount') {
            resetStatBoxFunction();
          }
          deleteUser(state: accountState);
          resetFunction(account: account);
          showFlutterToast(stringLabel: "Logged out");
        }
      },
      child: accountImageLink == ''
          ? Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: Center(
                child: Text(holderString),
              ),
            )
          : ShowProfilePicture(url: accountImageLink),
    );
  }
}
