import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/group/group_members.dart';
import 'package:sdk_tutorial/pages/group/update_group.dart';
import 'package:sdk_tutorial/pages/users/user_list.dart';

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
    String uid = "superhero1"; //new group owner uid

    await CometChat.transferGroupOwnership(
        guid: widget.groupId,
        uid: uid,
        onSuccess: (String message) {
          debugPrint("Owner Transferred  Successfully : $message");
        },
        onError: (CometChatException e) {
          debugPrint("Owner Transferred failed  : ${e.message}");
        });
  }

  addMembers(List<User> members) {
    //-----List of members to be added-----
    List<GroupMember> newGroupMembers = [];

    for (User user in members) {
      GroupMember newMember = GroupMember.fromUid(
          scope: CometChatMemberScope.participant,
          uid: user.uid,
          name: user.name);
      newGroupMembers.add(newMember);
    }

    CometChat.addMembersToGroup(
        guid: group.guid,
        groupMembers: newGroupMembers,
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
        title: const Text("Group Details"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Card(
                      child: SizedBox(
                          height: 72,
                          child: Center(
                            child: ListTile(
                              leading: CircleAvatar(
                                  child: Image.network(
                                group.icon,
                                errorBuilder: (context, object, trace) {
                                  return Text(group.name.substring(0, 1));
                                },
                              )),
                              title: Text(group.name),
                              subtitle: Text(
                                  "Members :${group.membersCount}  Type: ${group.type}"),
                            ),
                          )),
                    ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupMembers(
                                            groupId: group.guid,
                                          )));
                            },
                            title: const Text("View Members"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          )),
                    ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupMembers(
                                            groupId: group.guid,
                                            showBannedOnly: true,
                                          )));
                            },
                            title: const Text("View Banned Members"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          )),
                    ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: () async {
                                List<User> addMemberList = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CometChatUserList(
                                              navigateFrom:
                                                  NavigateFrom.addMembers,
                                            )));
                                addMembers(addMemberList);
                              },
                              title: const Text("Add Members"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            )),
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
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UpdateGroup(
                                              group: group,
                                            )));
                              },
                              title: const Text("Update This Group"),
                            )),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: transferOwnerShipOfGroup,
                              title: const Text(
                                "Transfer Ownership",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                    if (group.hasJoined)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: leaveGroup,
                              title: const Text(
                                "Leave This Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: deleteGroup,
                              title: const Text(
                                "Delete This Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
