import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime/mime.dart';
import 'package:sdk_tutorial/Utils/loading_indicator.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sdk_tutorial/pages/group/group_functions.dart';
import 'package:sdk_tutorial/pages/messages/media_message_widget.dart';
import 'package:sdk_tutorial/pages/messages/message_widget.dart';

import '../conversation_list.dart';
import '../users/user_details.dart';
// import 'package:mime/mime.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  final Conversation conversation;

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList>
    with MessageListener, GroupListener, UserListener {
  final List<BaseMessage> _messageList = <BaseMessage>[];
  final _itemFetcher = ItemFetcher<BaseMessage>();
  final textKey = const ValueKey<int>(1);

  String listenerId = "message_list_listener";

  bool _isLoading = true;
  bool _hasMore = true;
  MessagesRequest? messageRequest;
  String appTitle = "";
  String appSubtitle = "";
  Widget appBarAvatar = Container();
  final formKey = GlobalKey<FormState>();

  late BannedGroupMembersRequest bannedGroupMembersRequest;
  String messageText = "";
  bool typing = false;
  final FocusNode _focus = FocusNode();
  String conversationWithId = "";
  int activeParentMessageId = 103;

  @override
  void initState() {
    int limit = 2;
    if (widget.conversation.conversationType == "user") {
      conversationWithId = (widget.conversation.conversationWith as User).uid;
    } else {
      conversationWithId = (widget.conversation.conversationWith as Group).guid;
    }

    _focus.addListener(_onFocusChange);
    String? _avatar;
    CometChat.addMessageListener("listenerId", this);
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      messageRequest = (MessagesRequestBuilder()
            ..uid = (widget.conversation.conversationWith as User).uid
            ..limit = limit
            ..hideDeleted = true)
          .build();
      appTitle = (widget.conversation.conversationWith as User).name;
      _avatar = (widget.conversation.conversationWith as User).avatar;
      appSubtitle = (widget.conversation.conversationWith as User).status ?? '';
    } else {
      messageRequest = (MessagesRequestBuilder()
            ..guid = (widget.conversation.conversationWith as Group).guid
            ..limit = limit
            ..hideDeleted = true)
          .build();
      appTitle = (widget.conversation.conversationWith as Group).name;
      _avatar = (widget.conversation.conversationWith as Group).icon;
      appSubtitle =
          "${(widget.conversation.conversationWith as Group).membersCount.toString()} members";
    }
    appBarAvatar = Hero(
      tag: widget.conversation,
      child: CircleAvatar(
          child: _avatar != null && _avatar.trim() != ''
              ? Image.network(
                  _avatar,
                )
              : Text(appTitle.substring(0, 2))),
    );

    super.initState();
    _isLoading = true;
    _hasMore = true;
    _loadMore();
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      if (widget.conversation.conversationType == CometChatReceiverType.user) {
        User tempEntity = widget.conversation.conversationWith as User;
        CometChat.startTyping(
          receaverUid: tempEntity.uid,
          receiverType: CometChatReceiverType.user,
        );
      } else {
        Group startTyping = widget.conversation.conversationWith as Group;
        CometChat.startTyping(
          receaverUid: startTyping.guid,
          receiverType: CometChatReceiverType.group,
        );
      }
    } else if (!_focus.hasFocus) {
      if (widget.conversation.conversationType == CometChatReceiverType.user) {
        User tempEntity = widget.conversation.conversationWith as User;
        CometChat.endTyping(
            receaverUid: tempEntity.uid,
            receiverType: CometChatReceiverType.user);
      } else {
        Group tempEntity = widget.conversation.conversationWith as Group;
        CometChat.endTyping(
            receaverUid: tempEntity.guid,
            receiverType: CometChatReceiverType.group);
      }
    }
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();

    CometChat.removeMessageListener(listenerId);
  }

  @override
  void onTextMessageReceived(TextMessage textMessage) async {
    _messageList.insert(0, textMessage);
    setState(() {});
    CometChat.markAsRead(textMessage, onSuccess: (_) {}, onError: (_) {});
  }

  @override
  void onTypingStarted(TypingIndicator typingIndicator) {
    setState(() {
      if (typingIndicator.sender.uid.toLowerCase().trim() ==
          conversationWithId.toLowerCase().trim()) {
        typing = true;
      }
    });
  }

  @override
  void onTypingEnded(TypingIndicator typingIndicator) {
    setState(() {
      if (typingIndicator.sender.uid.toLowerCase().trim() ==
          conversationWithId.toLowerCase().trim()) {
        typing = false;
      }
    });
  }

  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) {
    if (mounted == true) {
      _messageList.insert(0, mediaMessage);
      setState(() {});
    }

    CometChat.markAsRead(mediaMessage, onSuccess: (_) {}, onError: (_) {});
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    for (int i = 0; i < _messageList.length; i++) {
      if (_messageList[i].sender!.uid == USERID &&
          _messageList[i].id <= messageReceipt.messageId &&
          _messageList[i].deliveredAt == null) {
        _messageList[i].deliveredAt = messageReceipt.deliveredAt;
      }
    }
    setState(() {});
  }

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    for (int i = 0; i < _messageList.length; i++) {
      if (_messageList[i].sender!.uid == USERID &&
          _messageList[i].id <= messageReceipt.messageId &&
          _messageList[i].readAt == null) {
        _messageList[i].readAt = messageReceipt.readAt;
      }
    }
    setState(() {});
  }

  @override
  void onMessageEdited(BaseMessage message) {
    // TODO: implement onMessageEdited
    if (mounted == true) {
      for (int count = 0; count < _messageList.length; count++) {
        if (message.id == _messageList[count].id) {
          _messageList[count] = message;
          setState(() {});
          break;
        }
      }
    }
  }

  @override
  void onMessageDeleted(BaseMessage message) {
    int matchingIndex =
        _messageList.indexWhere((element) => (element.id == message.id));

    _messageList.removeAt(matchingIndex);
    setState(() {});
  }

  @override
  void onCustomMessageReceived(CustomMessage customMessage) {
    // TODO: implement onCustomMessageReceived
    debugPrint("Custom message received successfully: $customMessage");

    if (customMessage.parentMessageId == activeParentMessageId) {
      debugPrint("Media message received successfully: $customMessage");
    }
  }

  // Triggers fecth() and then add new items or change _hasMore flag
  void _loadMore() {
    _isLoading = true;
    _itemFetcher.fetch(messageRequest).then((List<BaseMessage> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          for (var item in fetchedList) {
            print(
                " Before Adding to list ${item.id} ${item.type} ${item.category} ${(item is TextMessage) ? "start${item.text}end" : "sss"}");
          }
          _messageList.addAll(fetchedList.reversed);
        });
      }
    });
  }

  markRead(BaseMessage message) {
    CometChat.markAsRead(message, onSuccess: (String unused) {
      debugPrint("markAsRead : $unused ");
      reinitiateList();
    }, onError: (CometChatException e) {
      debugPrint("markAsRead unsuccessful : ${e.message} ");
    });
  }

  markDelivered(BaseMessage message) {
    CometChat.markAsDelivered(message, onSuccess: (String unused) {
      debugPrint("markAsDelivered : $unused ");
      reinitiateList();
    }, onError: (CometChatException e) {
      debugPrint("markAsDelivered unsuccessful : ${e.message} ");
    });
  }

  reinitiateList() {
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      messageRequest = (MessagesRequestBuilder()
            ..uid = (widget.conversation.conversationWith as User).uid)
          .build();
    } else {
      messageRequest = (MessagesRequestBuilder()
            ..guid = (widget.conversation.conversationWith as Group).guid)
          .build();
    }

    _messageList.clear();
    _isLoading = true;
    _hasMore = true;
    _loadMore();
    setState(() {});
  }

  getUnreadMessageCount(bool hideBlockedUser) async {
    CometChat.getUnreadMessageCount(
        hideMessagesFromBlockedUsers: hideBlockedUser,
        onSuccess: (Map<String, Map<String, int>> map) {
          debugPrint(map.toString());
        },
        onError: (e) {
          debugPrint(e.toString());
        });
  }

  Future<void> blockUser() async {
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      final String uid = (widget.conversation.conversationWith as User).uid;

      await CometChat.blockUser([uid], onSuccess: (Map<String, dynamic> map) {
        debugPrint("Blocked User Successfully $map ");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("User Blocked"),
        ));
      }, onError: (CometChatException e) {
        debugPrint("Blocked User Unsuccessful ${e.message} ");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${e.message}"),
        ));
      });
    }
  }

  deleteMessage(BaseMessage message) async {
    int matchingIndex =
        _messageList.indexWhere((element) => (element.id == message.id));

    await CometChat.deleteMessage(message.id,
        onSuccess: (_) {}, onError: (_) {});

    _messageList.removeAt(matchingIndex);
    setState(() {});
  }

  unblockUser() async {
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      final String uid = (widget.conversation.conversationWith as User).uid;
      await CometChat.unblockUser([uid],
          onSuccess: (onSuccess) {}, onError: (error) {});
    }
  }

  deleteConersation() async {
    String conversationWith = "";
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      conversationWith = (widget.conversation.conversationWith as User).uid;
    } else {
      conversationWith = (widget.conversation.conversationWith as Group).guid;
    }
    await CometChat.deleteConversation(
        conversationWith, widget.conversation.conversationType,
        onSuccess: (onSuccess) {}, onError: (error) {});
  }

  getGroup() {
    if (widget.conversation.conversationType == CometChatReceiverType.group) {
      String conversationWith =
          (widget.conversation.conversationWith as Group).guid;
      CometChat.getGroup(conversationWith, onSuccess: (Group group) {
        debugPrint("Fetched Group Successfully : $group ");
      }, onError: (CometChatException e) {
        debugPrint("Group Request failed with exception: ${e.message}");
      });
    }
  }

  getOnlineGroupMemberCount() {
    if (widget.conversation.conversationType == CometChatReceiverType.group) {
      String conversationWith =
          (widget.conversation.conversationWith as Group).guid;
      CometChat.getOnlineGroupMemberCount([conversationWith],
          onSuccess: (Map<String, int> count) {
        debugPrint("Fetched Online Group Member Count Successfully : $count ");
      }, onError: (CometChatException e) {
        debugPrint("Online Group Member  failed with exception: ${e.message}");
      });
    }
  }

  leaveGroup() {
    if (widget.conversation.conversationType == CometChatReceiverType.group) {
      String guid = (widget.conversation.conversationWith as Group).guid;
      CometChat.leaveGroup(guid, onSuccess: (String message) {
        debugPrint("Group Left  Successfully : $message");
      }, onError: (CometChatException e) {
        debugPrint("Group Left failed  : ${e.message}");
      });
    }
  }

  transferGroupOwnership() {
    if (widget.conversation.conversationType == CometChatReceiverType.group) {
      String conversationWith =
          (widget.conversation.conversationWith as Group).guid;
      String uid = "superhero1";
      String guid = conversationWith;
      CometChat.transferGroupOwnership(
          guid: guid,
          uid: uid,
          onSuccess: (String message) {
            debugPrint("Owner Transferred  Successfully : $message");
          },
          onError: (CometChatException e) {
            debugPrint("Owner Transferred failed  : ${e.message}");
          });
    }
  }

  addMessage() {
    CometChat.addMessageListener("listenerId", MessageListener());
  }

  tagConversation() {
    String conversationWith = ""; //id of the user/group
    String conversationType = "";
    List<String> tags = [];
    tags.add("archived");
    if (widget.conversation.conversationType == CometChatReceiverType.group) {
      conversationWith = (widget.conversation.conversationWith as Group).guid;
    } else {
      conversationWith = (widget.conversation.conversationWith as User).uid;
    }
    conversationType = widget.conversation.conversationType;

    CometChat.tagConversation(conversationWith, conversationType, tags,
        onSuccess: (Conversation conversation) {
      debugPrint("Conversation tagged Successfully : $conversation");
    }, onError: (CometChatException e) {
      debugPrint("Conversation tagging failed  : ${e.message}");
    });
  }

  getConversation() {
    String conversationWith = "superhero1"; //id of the user/group
    String conversationType = "user";
    CometChat.getConversation(conversationWith, conversationType,
        onSuccess: (Conversation conversation) {
      debugPrint("Fetch Conversation Successfully : $conversation");
    }, onError: (CometChatException e) {
      debugPrint("Fetch Conversation  failed  : ${e.message}");
    });
  }

  sendCustomMessage() {
    String uid = "UID";
    String subType = "LOCATION";
    String receiverType = CometChatConversationType.user;
    String type = CometChatMessageType.custom;
    Map<String, String> customData = {};
    customData["lattitue"] = "19.0760";
    customData["longitude"] = "72.8777";

    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      uid = (widget.conversation.conversationWith as User).uid;
    } else {
      uid = (widget.conversation.conversationWith as Group).guid;
    }

    CustomMessage customMessage = CustomMessage(
      receiverUid: uid,
      type: type,
      customData: customData,
      receiverType: receiverType,
      subType: subType,
    );

    CometChat.sendCustomMessage(customMessage,
        onSuccess: (CustomMessage message) {
      debugPrint("Custom Message Sent Successfully : $message");
    }, onError: (CometChatException e) {
      debugPrint("Custom message sending failed with exception: ${e.message}");
    });
  }

  getLastMessageId() async {
    int? ab = await CometChat.getLastDeliveredMessageId();
    debugPrint("$ab");
  }

  Future<void> deleteGroup() async {
    String guid = "";
    return await CometChat.deleteGroup(guid, onSuccess: (String message) {
      debugPrint("Deleted Group Successfully : $message ");
    }, onError: (CometChatException e) {
      debugPrint("Delete Group failed with exception: ${e.message}");
    });
  }

  Widget getTypingIndicator() {
    return Row(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Typing...",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget getMessageComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff141414).withOpacity(0.06),
          borderRadius: const BorderRadius.all(
              Radius.circular(8.0) //                 <--- border radius here
              ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  cursorColor: const Color(0xff141414).withOpacity(0.58),
                  focusNode: _focus,
                  controller: TextEditingController(text: messageText),
                  onChanged: (val) {
                    messageText = val;
                  },
                  decoration: const InputDecoration(
                    hintText: "Message",
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ))
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/PlusCircle.svg",
                    width: 24,
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          iconSize: 24,
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(),
                          icon: SvgPicture.asset(
                            "assets/Sticker.svg",
                            width: 24,
                            height: 24,
                          ),
                          onPressed: sendMediaMessage //do something,
                          ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          iconSize: 24,
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(),
                          icon: SvgPicture.asset(
                            "assets/Send.svg",
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            sendTextMessage();
                          } //do something,
                          ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getMessageWidget(int index) {
    if (_messageList[index] is MediaMessage) {
      return MediaMessageWidget(
        passedMessage: (_messageList[index] as MediaMessage),
      );
    }
    if (_messageList[index] is TextMessage) {
      return MessageWidget(
        passedMessage: (_messageList[index] as TextMessage),
        deleteFunction: deleteMessage,
      );
    }

    return const Text("No match");
  }

  sendMediaMessage() async {
    late String receiverID;
    String messageType = CometChatMessageType.image;
    String receiverType = widget.conversation.conversationType;
    String filePath = "";
    if (widget.conversation.conversationType == "user") {
      receiverID = (widget.conversation.conversationWith as User).uid;
    } else {
      receiverID = (widget.conversation.conversationWith as Group).guid;
    }

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    //String messageType = CometChatMessageType.file;

    if (result != null && result.files.single.path != null) {
      filePath = result.files.single.path!;

      String? fileExtension = lookupMimeType(result.files.single.path!);
      if (fileExtension != null) {
        if (fileExtension.startsWith("audio")) {
          messageType = CometChatMessageType.audio;
        } else if (fileExtension.startsWith("image")) {
          messageType = CometChatMessageType.image;
        } else if (fileExtension.startsWith("video")) {
          messageType = CometChatMessageType.video;
        } else if (fileExtension.startsWith("application")) {
          messageType = CometChatMessageType.file;
        } else {
          messageType = CometChatMessageType.file;
        }
      }

      MediaMessage mediaMessage = MediaMessage(
          receiverType: receiverType,
          type: messageType,
          receiverUid: receiverID,
          file: filePath);

      await CometChat.sendMediaMessage(mediaMessage,
          onSuccess: (MediaMessage message) {
        debugPrint("Media message sent successfully: ${mediaMessage.metadata}");
        _messageList.insert(0, message);
        setState(() {});
      }, onError: (e) {
        debugPrint("Media message sending failed with exception: ${e.message}");
      });
    } else {
      // User canceled the picker
    }
  }

  sendTextMessage() {
    late String receiverID;
    String messagesText = messageText;
    String receiverType = CometChatConversationType.user;
    String type = CometChatMessageType.text;

    if (widget.conversation.conversationType == "user") {
      receiverID = (widget.conversation.conversationWith as User).uid;
    } else {
      receiverID = (widget.conversation.conversationWith as Group).guid;
    }
    TextMessage textMessage = TextMessage(
        text: messagesText,
        receiverUid: receiverID,
        receiverType: receiverType,
        type: type);

    textMessage.id = 46;

    CometChat.sendMessage(textMessage, onSuccess: (TextMessage message) {
      debugPrint("Message sent successfully:  ${message.text}");

      setState(() {
        _messageList.insert(0, message);
        messageText = "";
      });
    }, onError: (CometChatException e) {
      debugPrint("Message sending failed with exception:  ${e.message}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: appBarAvatar,
          subtitle: Text(
            appSubtitle,
            style: TextStyle(color: Colors.white),
          ),
          title: Text(
            appTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                if (widget.conversation.conversationWith is Group) {
                  Group group = widget.conversation.conversationWith as Group;

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupFunctions(
                                groupId: group.guid,
                                loggedInUserId: USERID,
                              )));
                } else {
                  User user = widget.conversation.conversationWith as User;

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserDetails(
                                user: user,
                              )));
                }
              },
              icon: Icon(Icons.info_outline)),
          PopupMenuButton<int>(
            onSelected: (item) {
              switch (item) {
                case 0:
                  blockUser();
                  break;

                case 2:
                  getUnreadMessageCount(true);
                  break;

                case 5:
                  unblockUser();
                  break;
                case 7:
                  getGroup();
                  break;
                case 9:
                  getOnlineGroupMemberCount();
                  break;
                case 15:
                  leaveGroup();
                  break;
                case 16:
                  transferGroupOwnership();
                  break;
                case 20:
                  sendCustomMessage();
                  break;
                case 21:
                  getLastMessageId();
                  break;
                case 22:
                  tagConversation();
                  break;
                default:
                  debugPrint("No action defined");
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Block')),
              const PopupMenuItem<int>(value: 2, child: Text('unread Count')),
              const PopupMenuItem<int>(value: 5, child: Text('Unblock user')),
              const PopupMenuItem<int>(value: 7, child: Text('getGroup')),
              const PopupMenuItem<int>(
                  value: 9, child: Text('getOnlineGroupMemberCount')),
              const PopupMenuItem<int>(value: 15, child: Text('Leave Group')),
              const PopupMenuItem<int>(
                  value: 16, child: Text('transferGroupOwnership')),
              const PopupMenuItem<int>(
                  value: 20, child: Text('Send Custom Message')),
              const PopupMenuItem<int>(
                  value: 21, child: Text('get Last Message id')),
              const PopupMenuItem<int>(
                  value: 22, child: Text('Tag Conversation')),
              const PopupMenuItem<int>(
                  value: 23, child: Text('get Conversation')),
            ],
          ),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              // to diisplay loading tile if more items
              itemCount:
                  _hasMore ? _messageList.length + 1 : _messageList.length,
              itemBuilder: (BuildContext context, int index) {
                // Uncomment the following line to see in real time how ListView.builder works
                // print('ListView.builder is building index $index');
                if (index >= _messageList.length) {
                  // Don't trigger if one async loading is already under way
                  if (!_isLoading) {
                    _loadMore();
                  }
                  return const LoadingIndicator();
                }
                return getMessageWidget(index);
              },
            ),
          ),
          if (typing == true) getTypingIndicator(),
          getMessageComposer()
        ],
      )),
    );
  }
}
