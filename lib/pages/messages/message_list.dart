
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:mime/mime.dart';
import 'package:sdk_tutorial/Utils/loading_indicator.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sdk_tutorial/pages/messages/media_message_widget.dart';
import 'package:sdk_tutorial/pages/messages/message_widget.dart';
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

class _MessageListState extends State<MessageList> with MessageListener {
  final List _messageList = <BaseMessage>[];
  final _itemFetcher = ItemFetcher<BaseMessage>();
  final textKey = const ValueKey<int>(1);

  bool _isLoading = true;
  bool _hasMore = true;
  MessagesRequest? messageRequest;
  String appTitle = "";
  final formKey = GlobalKey<FormState>();

  late BannedGroupMembersRequest bannedGroupMembersRequest;
  String messageText = "";
  bool typing = false;
  final FocusNode _focus =  FocusNode();
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

    CometChat.addMessageListener("listenerId", this);
    if (widget.conversation.conversationType == CometChatReceiverType.user) {
      messageRequest = (MessagesRequestBuilder()
            ..uid = (widget.conversation.conversationWith as User).uid
            ..limit = limit)
          .build();
      appTitle = (widget.conversation.conversationWith as User).name;
    } else {
      messageRequest = (MessagesRequestBuilder()
            ..guid = (widget.conversation.conversationWith as Group).guid
            ..limit = limit)
          .build();
      appTitle = (widget.conversation.conversationWith as Group).name;
    }

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
    // TODO: implement dispose
    super.dispose();
    _focus.removeListener(_onFocusChange);
    CometChat.removeMessageListener("listenerId");
    _focus.dispose();
  }

  @override
  void onTextMessageReceived(TextMessage textMessage) async {

    _messageList.add(textMessage);
    setState(() {

    });

    CometChat.markAsDelivered(textMessage, onSuccess: (_){}, onError: (_){});

  }

  @override
  void onTypingStarted(TypingIndicator typingIndicator) {
    // TODO: implement onTypingStarted

    setState(() {
      if (typingIndicator.sender.uid.toLowerCase().trim() ==
          conversationWithId.toLowerCase().trim()) {
        typing = true;
      }
    });
  }

  @override
  void onTypingEnded(TypingIndicator typingIndicator) {
    // TODO: implement onTypingEnded
    setState(() {
      if (typingIndicator.sender.uid.toLowerCase().trim() ==
          conversationWithId.toLowerCase().trim()) {
        typing = false;
      }
    });
  }

  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) {
    // TODO: implement onMediaMessageReceived


    if (mounted == true) {
      _messageList.insert(0, mediaMessage);
      setState(() {});
    }
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    // TODO: implement onMessagesDelivered
    if (mounted == true) {
      for (int i = 0; i < _messageList.length; i++) {
        if (_messageList[i].sender!.uid == USERID &&
            _messageList[i].id <= messageReceipt.messageId) {
          _messageList[i].deliveredAt = DateTime.now();
          _messageList[i].readAt = DateTime.now();
        }
      }
      setState(() {});
    }
  }

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    if (mounted == true) {
      //reinitiateList();
    }
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
    if (mounted == true) {
      for (int count = 0; count < _messageList.length; count++) {
        if (message.id == _messageList[count].id) {
          _messageList.removeAt(count);
          setState(() {});
          break;
        }
      }
    }
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
        onSuccess: (onSuccess) {
    }, onError: (error) {});
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
    return Form(
      key: formKey,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {},
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.5),
              radius: 20,
              child: const Icon(Icons.add),
            ),
          ),
          Expanded(
              child: Stack(
            children: [
              TextFormField(
                focusNode: _focus,
                controller: TextEditingController(text: messageText),
                onChanged: (val) {
                  messageText = val;
                },
              ),
            ],
          )),
          FloatingActionButton(
              child: const Icon(Icons.attachment),
              backgroundColor: const Color(0xff131513),
              heroTag: "firstTag",
              onPressed: () async {
                late String receiverID;
                String messageType = CometChatMessageType.image;
                String receiverType = widget.conversation.conversationType;
                String filePath = "";
                if (widget.conversation.conversationType == "user") {
                  receiverID =
                      (widget.conversation.conversationWith as User).uid;
                } else {
                  receiverID =
                      (widget.conversation.conversationWith as Group).guid;
                }

                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.any);
                //String messageType = CometChatMessageType.file;

                if (result != null && result.files.single.path != null) {
                  // File file = File(result.files.single.path!);
                  // print(lookupMimeType(result.files.single.path!));
                  filePath = result.files.single.path!;

                  String? fileExtension =
                      lookupMimeType(result.files.single.path!);
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

                  // Map<String, dynamic> metadata = {};
                  // metadata["lattitude"] = "50.6192171633316";
                  // metadata["longitude"] = "-72.68182268750002";
                  // mediaMessage.metadata = metadata;
                  //
                  // List<String> tags = [];
                  // tags.add("pinned");
                  // mediaMessage.tags = tags;
                  //
                  // mediaMessage.caption = "Message Caption";

                  await CometChat.sendMediaMessage(mediaMessage,
                      onSuccess: (MediaMessage message) {
                    debugPrint(
                        "Media message sent successfully: ${mediaMessage.metadata}");
                    _messageList.insert(0, message);
                    setState(() {});
                  }, onError: (e) {
                    debugPrint(
                        "Media message sending failed with exception: ${e.message}");
                  });
                } else {
                  // User canceled the picker
                }
              }),
          FloatingActionButton(
              child: const Icon(Icons.send),
              backgroundColor: const Color(0xff131513),
              heroTag: "secondTag",
              onPressed: () {
                FocusScope.of(context).requestFocus( FocusNode());

                late String receiverID;
                String messagesText = messageText;
                String receiverType = CometChatConversationType.user;
                String type = CometChatMessageType.text;

                if (widget.conversation.conversationType == "user") {
                  receiverID =
                      (widget.conversation.conversationWith as User).uid;
                } else {
                  receiverID =
                      (widget.conversation.conversationWith as Group).guid;
                }
                TextMessage textMessage = TextMessage(
                    text: messagesText,
                    receiverUid: receiverID,
                    receiverType: receiverType,
                    type: type);

                textMessage.id = 46;

                CometChat.sendMessage(textMessage,
                    onSuccess: (TextMessage message) {
                  debugPrint("Message sent successfully:  ${message.text}");

                  setState(() {
                    _messageList.insert(0, message);
                    messageText = "";
                  });
                }, onError: (CometChatException e) {
                  debugPrint(
                      "Message sending failed with exception:  ${e.message}");
                });
              }),
          FloatingActionButton(
              child: const Icon(Icons.link),
              backgroundColor: const Color(0xff131513),
              onPressed: () async {
                late String receiverID;
                String messageType = CometChatMessageType.image;
                String receiverType = widget.conversation.conversationType;
                if (widget.conversation.conversationType == "user") {
                  receiverID =
                      (widget.conversation.conversationWith as User).uid;
                } else {
                  receiverID =
                      (widget.conversation.conversationWith as Group).guid;
                }
                messageType = CometChatMessageType.image;

                MediaMessage mediaMessage = MediaMessage(
                    receiverType: receiverType,
                    type: messageType,
                    receiverUid: receiverID,
                    file: null);

                String fileUrl =
                    "https://pngimg.com/uploads/mario/mario_PNG125.png";
                String fileName = "test";
                String fileExtension = "png";
                String fileMimeType = "image/png";

                Attachment attach = Attachment(
                    fileUrl, fileName, fileExtension, fileMimeType, null);
                mediaMessage.attachment = attach;

                await CometChat.sendMediaMessage(mediaMessage,
                    onSuccess: (MediaMessage message) {
                  debugPrint(
                      "Media message sent successfully: ${mediaMessage.metadata}");
                  _messageList.insert(0, message);
                  setState(() {});
                }, onError: (CometChatException e) {
                  debugPrint(
                      "Media message sending failed with exception: ${e.message}");
                });

                String receiverId = "superhero2";
                Map<String, String> data = {};
                data["LIVE_REACTION"] = "heart";

                TransientMessage transientMessage = TransientMessage(
                  receiverId: receiverId,
                  receiverType: CometChatReceiverType.user,
                  data: data,
                );

                CometChat.sendTransientMessage(transientMessage, onSuccess: () {
                  debugPrint("Transient Message Sent");
                }, onError: (CometChatException e) {
                  debugPrint(
                      "Transient message sending failed with exception: ${e.message}");
                });
              })
        ],
      ),
    );
  }

  Widget getMessageWidget(int index) {
    // return MessageWidget(
    //     passedMessage: (_messageList[index] as TextMessage),
    // );

      //Text((_messageList[index] as TextMessage).text);

    if (_messageList[index] is MediaMessage) {
      return MediaMessageWidget(
          passedMessage: (_messageList[index] as MediaMessage),
         );
    }
    if (_messageList[index] is TextMessage) {
      return MessageWidget(
            passedMessage: (_messageList[index] as TextMessage),
        );
    }

    return const Text("No match");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: <Widget>[
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

class ItemFetcher<T> {
  Future<List<T>> fetch(dynamic request) async {
    final list = <T>[];

    List<T> res = await request.fetchPrevious(
        onSuccess: (List<T> messages) {}, onError: (CometChatException e) {});

    list.addAll(res);
    return list;
  }
}
