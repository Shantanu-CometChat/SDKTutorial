import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';
import 'package:sdk_tutorial/pages/group_list.dart';
import 'package:sdk_tutorial/pages/user_list.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await CometChat.logout(
            onError: (CometChatException exception) {},
            onSuccess: (Map<String, Map<String, int>> message) {});
        Navigator.of(context).pop();
        USERID = "";
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SDK Tutorial"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //-------Conversation List-------
              Card(
                elevation: 5,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConversationList()));
                  },
                  title: const Text("Conversation List"),
                ),
              ),

              //-------User List-------
              Card(
                elevation: 5,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CometChatUserList()));
                  },
                  title: const Text("User List"),
                ),
              ),

              //-------Group List-------
              Card(
                elevation: 5,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CometChatGroupList()));
                  },
                  title: const Text("Group List"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
