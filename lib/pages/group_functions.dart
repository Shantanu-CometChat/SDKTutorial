import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/update_group.dart';

class GroupFunctions extends StatefulWidget {
  const GroupFunctions(
      {Key? key, required this.groupId, required this.loggedInUserId})
      : super(key: key);
  final String groupId;
  final String loggedInUserId;

  @override
  _GroupFunctionsState createState() => _GroupFunctionsState();
}

class _GroupFunctionsState extends State<GroupFunctions> {
  late Group group;
  bool isLoading = true;
  bool isGroupOwner = false;
  String groupPassword = "";
  String addMemberUid = "";

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  getGroupDetails() async {
    await CometChat.getGroup(widget.groupId, onSuccess: (Group fetchGroup) {
      debugPrint("Fetched Group Successfully : $fetchGroup ");
      group = fetchGroup;
    }, onError: (CometChatException e) {
      debugPrint("Group Request failed with exception: ${e.message}");
      return;
    });

    isGroupOwner = group.owner == widget.loggedInUserId;
    isLoading = false;
    setState(() {});
    print("Group owner ${group.owner}");
    print(widget.loggedInUserId);
  }

  leaveGroup() async {
    await CometChat.leaveGroup(widget.groupId, onSuccess: (String message) {
      debugPrint("Group Left  Successfully : $message");
    }, onError: (CometChatException e) {
      debugPrint("Group Left failed  : ${e.message}");
    });
  }

  joinGroup() async {
    await CometChat.joinGroup(group.guid, group.type, password: groupPassword,
        onSuccess: (Group group) {
      debugPrint("Group Joined Successfully : $group ");
    }, onError: (CometChatException e) {
      debugPrint("Group Joining failed with exception: ${e.message}");
    });
    setState(() {});
  }

  deleteGroup() async {
    await CometChat.deleteGroup(widget.groupId, onSuccess: (String message) {
      debugPrint("Deleted Group Successfully : $message ");
    }, onError: (CometChatException e) {
      debugPrint("Delete Group failed with exception: ${e.message}");
    });
  }

  transferOwnerShipOfGroup() async {
    String UID = "superhero1"; //new group owner uid

    await CometChat.transferGroupOwnership(
        guid: widget.groupId,
        uid: UID,
        onSuccess: (String message) {
          debugPrint("Owner Transferred  Successfully : $message");
        },
        onError: (CometChatException e) {
          debugPrint("Owner Transferred failed  : ${e.message}");
        });
  }

  addMembers() {
    GroupMember firstMember = GroupMember.fromUid(
        scope: CometChatMemberScope.participant,
        uid: addMemberUid,
        name: "name");

    //-----List of members to be added-----
    List<GroupMember> groupMembers = [firstMember];

    CometChat.addMembersToGroup(
        guid: group.guid,
        groupMembers: groupMembers,
        onSuccess: (Map<String?, String?> result) {
          debugPrint("Group Member added Successfully : $result");
        },
        onError: (CometChatException e) {
          debugPrint(
              "Group Member addition failed with exception: ${e.message}");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Functionality"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    if (group.hasJoined)
                      MaterialButton(
                          color: Colors.blue,
                          minWidth: 200,
                          onPressed: leaveGroup,
                          child: const Text("Leave This Group")),
                    SizedBox(
                      height: 10,
                    ),
                    if (group.type == CometChatGroupType.password &&
                        !group.hasJoined)
                      Container(
                        width: 250,
                        padding: const EdgeInsets.all(15),
                        child: TextField(
                          onChanged: (val) {
                            groupPassword = val;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Group Password',
                          ),
                        ),
                      ),
                    if (!group.hasJoined)
                      MaterialButton(
                          color: Colors.blue,
                          minWidth: 200,
                          onPressed: joinGroup,
                          child: const Text("Join This Group")),
                    if (group.owner == widget.loggedInUserId)
                      Container(
                        width: 250,
                        child: TextField(
                          onChanged: (val) {
                            addMemberUid = val;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'UID',
                            hintText: 'Add Member UID',
                          ),
                        ),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      MaterialButton(
                        color: Colors.blue,
                        minWidth: 200,
                        onPressed: addMembers,
                        child: Text("AddMembers"),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      MaterialButton(
                          color: Colors.blue,
                          minWidth: 200,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateGroup(
                                          group: group,
                                        )));
                          },
                          child: Text("Update This Group")),
                    if (group.owner == widget.loggedInUserId)
                      MaterialButton(
                          color: Colors.blue,
                          minWidth: 200,
                          onPressed: deleteGroup,
                          child: Text("Delete This Group")),
                    if (group.owner == widget.loggedInUserId)
                      MaterialButton(
                          color: Colors.blue,
                          minWidth: 200,
                          onPressed: transferOwnerShipOfGroup,
                          child: Text("Transfer Ownership"))
                  ],
                ),
              ),
            ),
    );
  }
}
