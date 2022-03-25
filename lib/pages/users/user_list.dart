import 'dart:convert';

import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';
import 'package:sdk_tutorial/pages/users/create_user.dart';
import 'package:sdk_tutorial/pages/users/update_user.dart';
import 'package:http/http.dart' as http;
import 'package:sdk_tutorial/pages/users/user_details.dart';

import '../../constants.dart';

enum NavigateFrom { addMembers, userList }

class CometChatUserList extends StatefulWidget {
  const CometChatUserList({Key? key, required this.navigateFrom})
      : super(key: key);
  final NavigateFrom navigateFrom;

  @override
  _CometChatUserListState createState() => _CometChatUserListState();
}

class _CometChatUserListState extends State<CometChatUserList> {
  List<User> userList = [];
  List<User> addMemberList = [];
  Set<int> selectedIndex = {};

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
  loadMoreUsers() async {
    isLoading = true;

    await usersRequest.fetchNext(
        onSuccess: (List<User> fetchedList) {
          //-----if fetch list is empty then there no more users left----
          debugPrint(fetchedList.toString());

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
        },
        onError: (CometChatException exception) {});
  }

  //-----deleting user using http request-----
  deleteUser(String uid, int index) async {
    String appId = CometChatAuthConstants.appId;
    String region = CometChatAuthConstants.region;
    String apiKey = CometChatAuthConstants.apiKey;

    Uri url =
        Uri.parse('https://$appId.api-$region.cometchat.io/v3/users/$uid');
    Map<String, String> headers = {
      'apiKey': apiKey,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> body = {
      "permanent":
          true //Permanently deletes the user along with all the messages, conversations, etc.optional
    };

    var response =
        await http.delete(url, body: jsonEncode(body), headers: headers);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data["data"]["success"] == true) {
        userList.removeAt(index);
        setState(() {});
      }
    } else {
      debugPrint(response.body);
    }
  }

  Widget getUserListMenuOptions(User user, int index) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'Update') {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateUser(
                        user: user,
                        updateLoggedInUser: false,
                      )));

          CometChat.getUser(user.uid, onSuccess: (User user) {
            setState(() {
              userList[index] = user;
            });
          }, onError: (CometChatException e) {});
        } else if (value == 'Delete') {
          deleteUser(user.uid, index);
        } else if (value == 'Details') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDetails(
                        user: user,
                      )));
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Details', 'Update', 'Delete'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.navigateFrom == NavigateFrom.userList
              ? const Text('Users')
              : const Text("Add Members"),
          actions: [
            if (widget.navigateFrom == NavigateFrom.addMembers &&
                selectedIndex.isNotEmpty)
              IconButton(
                  onPressed: () {
                    Navigator.pop(context, addMemberList);
                  },
                  icon: const Icon(Icons.check))
          ],
        ),
        floatingActionButton: widget.navigateFrom == NavigateFrom.userList
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateUser()));
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: hasMoreUsers ? userList.length + 1 : userList.length,
          itemBuilder: (context, index) {
            if (index >= userList.length && hasMoreUsers) {
              //-----if end of list then fetch more users-----
              if (!isLoading) {
                loadMoreUsers();
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = userList[index];

            return Card(
              elevation: 8,
              color: selectedIndex.contains(index) ? Colors.grey : Colors.white,
              child: SizedBox(
                  height: 72,
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        if (widget.navigateFrom == NavigateFrom.addMembers &&
                            !selectedIndex.contains(index)) {
                          addMemberList.add(user);
                          selectedIndex.add(index);
                          setState(() {});
                        } else if (widget.navigateFrom ==
                                NavigateFrom.addMembers &&
                            selectedIndex.contains(index)) {
                          selectedIndex.remove(index);
                          addMemberList.remove(user);
                          setState(() {});
                        }
                      },
                      leading: CircleAvatar(
                          child: Stack(
                        children: [
                          CircleAvatar(
                              child:
                                  user.avatar != null && user.avatar!.isNotEmpty
                                      ? Image.network(user.avatar!)
                                      : Text(user.name.substring(0, 1))),
                          if (widget.navigateFrom == NavigateFrom.userList &&
                              user.status != null)
                            Positioned(
                              height: 12,
                              width: 12,
                              right: 1,
                              bottom: 1,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                    color: user.status ==
                                            CometChatUserStatus.online
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                        ],
                      )),
                      title: Text(user.name),
                      subtitle: Text(user.uid),
                      trailing: widget.navigateFrom == NavigateFrom.userList
                          ? getUserListMenuOptions(user, index)
                          : null,
                    ),
                  )),
            );
          },
        ));
  }
}
