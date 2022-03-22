import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class CometChatUserList extends StatefulWidget {
  const CometChatUserList({Key? key}) : super(key: key);

  @override
  _CometChatUserListState createState() => _CometChatUserListState();
}

class _CometChatUserListState extends State<CometChatUserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: FutureBuilder<List<User>>(
          future: _initGetUsers(),
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userList = snapshot.data ?? [];
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];

                return Container(height: 72, child: Text(user.name));
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<User>> _initGetUsers() async {
    List<User> user = await (UsersRequestBuilder()..limit = 30)
        .build()
        .fetchNext(onSuccess: (List<User> userList) {
      debugPrint("User List Fetched Successfully : $userList");
    }, onError: (CometChatException e) {
      debugPrint("User List Fetch Failed: ${e.message}");
    });
    //Logger().d(user);

    return user;
  }
}
