import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class CometChatGroupList extends StatefulWidget {
  const CometChatGroupList({Key? key}) : super(key: key);

  @override
  _CometChatGroupListState createState() => _CometChatGroupListState();
}

class _CometChatGroupListState extends State<CometChatGroupList> {
  List<Group> groupList = [];

  bool isLoading = true;
  bool hasMoreGroups = true;

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
  void loadMoreGroups() {
    isLoading = true;

    groupsRequest.fetchNext(
        onSuccess: (List<Group> fetchedList) {
          //-----if fetch list is empty then there no more users left----
          print(fetchedList);

          if (fetchedList.isEmpty) {
            setState(() {
              isLoading = false;
              hasMoreGroups = false;
            });
          }
          //-----else more users will be fetch at end of list----
          else {
            setState(() {
              isLoading = false;
              groupList.addAll(fetchedList);
            });
          }
        },
        onError: (CometChatException exception) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: hasMoreGroups ? groupList.length + 1 : groupList.length,
          itemBuilder: (context, index) {
            if (index >= groupList.length && hasMoreGroups) {
              //-----if end of list then fetch more users-----
              loadMoreGroups();
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final group = groupList[index];

            return SizedBox(
                height: 72,
                child: ListTile(
                  leading: CircleAvatar(
                      child: Image.network(
                    group.icon,
                    errorBuilder: (context, object, trace) {
                      return Text(group.name.substring(0, 1));
                    },
                  )),
                  title: Text(group.name),
                ));
          },
        ),
      ),
    );
  }
}
