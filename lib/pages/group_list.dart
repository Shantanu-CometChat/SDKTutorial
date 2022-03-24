import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';
import 'package:sdk_tutorial/pages/create_group.dart';
import 'package:sdk_tutorial/pages/group_functions.dart';

class CometChatGroupList extends StatefulWidget {
  const CometChatGroupList({Key? key}) : super(key: key);

  @override
  _CometChatGroupListState createState() => _CometChatGroupListState();
}

class _CometChatGroupListState extends State<CometChatGroupList> {
  List<Group> groupList = [];

  bool isLoading = true;
  bool hasMoreGroups = true;
  final itemFetcher = ItemFetcher<Group>();
  late GroupsRequest groupsRequest;

  @override
  void initState() {
    super.initState();
    groupsRequest = (GroupsRequestBuilder()..limit = 30
        // ..searchKeyword = "abc"
        // ..joinedOnly = true
        // ..tags = []
        // ..withTags = true
        )
        .build();

    loadMoreGroups();
  }

  //Function to load more groups
  loadMoreGroups() async {
    isLoading = true;

    await itemFetcher.fetch(groupsRequest).then((List<Group> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          isLoading = false;
          hasMoreGroups = false;
        });
      } else {
        setState(() {
          isLoading = false;
          groupList.addAll(fetchedList);
        });
      }
    });

    // groupsRequest.fetchNext(
    //     onSuccess: (List<Group> fetchedList) {
    //       //-----if fetch list is empty then there no more users left----
    //       print(fetchedList);
    //
    //       if (fetchedList.isEmpty) {
    //         setState(() {
    //           isLoading = false;
    //           hasMoreGroups = false;
    //         });
    //       }
    //       //-----else more users will be fetch at end of list----
    //       else {
    //         setState(() {
    //           isLoading = false;
    //           groupList.addAll(fetchedList);
    //         });
    //       }
    //       print(hasMoreGroups);
    //     },
    //     onError: (CometChatException exception) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateGroup()));
          },
          child: const Icon(Icons.add)),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: hasMoreGroups ? groupList.length + 1 : groupList.length,
        itemBuilder: (context, index) {
          if (index >= groupList.length) {
            //-----if end of list then fetch more users-----
            if (!isLoading) loadMoreGroups();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final group = groupList[index];

          return Card(
            elevation: 8,
            child: SizedBox(
                height: 72,
                child: Center(
                  child: ListTile(
                    onTap: () async {
                      User? loggedInUser = await CometChat.getLoggedInUser();

                      if (loggedInUser != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupFunctions(
                                      groupId: group.guid,
                                      loggedInUserId: loggedInUser.uid,
                                    )));
                      }
                    },
                    leading: CircleAvatar(
                        child: Image.network(
                      group.icon,
                      errorBuilder: (context, object, trace) {
                        return Text(group.name.substring(0, 1));
                      },
                    )),
                    title: Text(group.name),
                  ),
                )),
          );
        },
      ),
    );
  }
}
