import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class CometChatGroupList extends StatefulWidget {
  const CometChatGroupList({Key? key}) : super(key: key);

  @override
  _CometChatGroupListState createState() => _CometChatGroupListState();
}

class _CometChatGroupListState extends State<CometChatGroupList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: FutureBuilder<List<Group>>(
          future: _initGetGroups(),
          builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final groupList = snapshot.data ?? [];
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                final group = groupList[index];

                return Text(group.name);
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Group>> _initGetGroups() async {
    List<Group> groups = await (GroupsRequestBuilder()..limit = 30)
        .build()
        .fetchNext(onSuccess: (List<Group> groupList) {
      debugPrint("Group List Fetched Successfully : $groupList");
    }, onError: (CometChatException e) {
      debugPrint("Group List Fetch Failed: ${e.message}");
    });
    //Logger().d(user);

    return groups;
  }
}
