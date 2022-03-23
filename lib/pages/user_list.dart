import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';

class CometChatUserList extends StatefulWidget {
  const CometChatUserList({Key? key}) : super(key: key);

  @override
  _CometChatUserListState createState() => _CometChatUserListState();
}

class _CometChatUserListState extends State<CometChatUserList> {
  List<User> userList = [];

  final itemFetcher = ItemFetcher<User>();
  bool isLoading = true;
  bool hasMoreUsers = true;

  late UsersRequest usersRequest;

  @override
  void initState() {
    super.initState();
    usersRequest = (UsersRequestBuilder()..limit = 30
        // ..searchKeyword = "abc"
        // ..userStatus = CometChatUserStatus.online
        // ..hideBlockedUsers = true
        // ..friendsOnly = true
        // ..tags = []
        // ..withTags = true
        // ..uids = []
        )
        .build();

    loadMoreUsers();
  }

  //Function to load more users
  void loadMoreUsers() {
    isLoading = true;

    usersRequest.fetchNext(
        onSuccess: (List<User> fetchedList) {
          //-----if fetch list is empty then there no more users left----
          print(fetchedList);

          if (fetchedList.isEmpty) {
            setState(() {
              isLoading = false;
              hasMoreUsers = false;
            });
          }
          //-----else more users will be fetch at end of list----
          else {
            setState(() {
              isLoading = false;
              userList.addAll(fetchedList);
            });
          }
          print(hasMoreUsers);
        },
        onError: (CometChatException exception) {});
  }

  Widget getUserListTile(User user) {
    return ListTile(
      leading: CircleAvatar(
          child: Image.network(
        user.avatar ?? '',
        errorBuilder: (context, object, trace) {
          return Text(user.name.substring(0, 1));
        },
      )),
      title: Text(user.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: hasMoreUsers ? userList.length + 1 : userList.length,
              itemBuilder: (context, index) {
                if (index >= userList.length && hasMoreUsers) {
                  //-----if end of list then fetch more users-----
                  loadMoreUsers();
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = userList[index];

                return SizedBox(
                    height: 72,
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Image.network(
                        user.avatar ?? '',
                        errorBuilder: (context, object, trace) {
                          return Text(user.name.substring(0, 1));
                        },
                      )),
                      title: Text(user.name),
                    ));
              },
            )));
  }
}
