import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  blockUser() {
    List<String> uids = [];
    uids.add(widget.user.uid);
    CometChat.blockUser(uids, onSuccess: (Map<String, dynamic> map) {
      debugPrint("Blocked User Successfully $map ");
      widget.user.blockedByMe = true;
      setState(() {});
    }, onError: (CometChatException e) {
      debugPrint("Blocked User Unsuccessful ${e.message} ");
    });
  }

  unblockUser() {
    List<String> uids = [];
    uids.add(widget.user.uid);

    CometChat.unblockUser(uids, onSuccess: (Map<String, dynamic> map) {
      debugPrint("Unblocked User Successfully $map ");
      widget.user.blockedByMe = false;
      setState(() {});
    }, onError: (CometChatException e) {
      debugPrint("Unblocked User Unsuccessful ${e.message} ");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: SizedBox(
                  height: 72,
                  child: Center(
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Stack(
                        children: [
                          CircleAvatar(
                              child: widget.user.avatar != null &&
                                      widget.user.avatar!.isNotEmpty
                                  ? Image.network(widget.user.avatar!)
                                  : Text(widget.user.name.substring(0, 1))),
                          if (widget.user.status != null)
                            Positioned(
                              height: 12,
                              width: 12,
                              right: 1,
                              bottom: 1,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                    color: widget.user.status ==
                                            CometChatUserStatus.online
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                        ],
                      )),
                      title: Text(widget.user.name),
                      subtitle: Text("UID: ${widget.user.uid}"),
                    ),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    title: const Text(
                      "Last Active at",
                      style: TextStyle(color: Colors.blue),
                    ),
                    trailing: Text(widget.user.lastActiveAt.toString()),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    title: const Text("Has Blocked Me"),
                    trailing: Text("${widget.user.hasBlockedMe}"),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () {
                      if (widget.user.blockedByMe ?? false) {
                        unblockUser();
                      } else {
                        blockUser();
                      }
                    },
                    title: widget.user.blockedByMe ?? false
                        ? const Text(
                            "Unblock",
                            style: TextStyle(color: Colors.blue),
                          )
                        : const Text(
                            "Block",
                            style: TextStyle(color: Colors.red),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
