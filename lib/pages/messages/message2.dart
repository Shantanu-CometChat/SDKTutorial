// import 'package:cometchat/cometchat_sdk.dart';
// import 'package:flutter/material.dart';
// import 'package:sdk_tutorial/pages/messages/message_list.dart';
//
// //----------- fetch items like conversation list,user list ,etc.-----------
// class ItemFetcher<T> {
//   Future<List<T>> fetch(dynamic request) async {
//     final list = <T>[];
//
//     List<T> res = await request.fetchNext(
//         onSuccess: (List<T> conversations) {},
//         onError: (CometChatException e) {});
//
//     list.addAll(res);
//     return list;
//   }
// }
//
// class MessageList extends StatefulWidget {
//   const MessageList({Key? key,
//     required this.conversation,
//   }) : super(key: key);
//
//
//   final Conversation conversation;
//
//   @override
//   _MessageListState createState() => _MessageListState();
// }
//
// class _MessageListState extends State<MessageList>
//     with MessageListener {
//   final List<BaseMessage> messageList = [];
//   final itemFetcher = ItemFetcher<BaseMessage>();
//
//   bool isLoading = true;
//   bool hasMoreItems = true;
//   late MessagesRequest messageRequest;
//   String appTitle = "";
//   int limit =20;
//   final formKey = GlobalKey<FormState>();
//   String messageText = "";
//
//   Map<int, bool> _typingIndicatorMap = {};
//   @override
//   void initState() {
//     super.initState();
//
//
//
//     CometChat.addMessageListener("listenerId", this);
//     if (widget.conversation.conversationType == CometChatReceiverType.user) {
//       messageRequest = (MessagesRequestBuilder()
//         ..uid = (widget.conversation.conversationWith as User).uid
//         ..limit = limit)
//           .build();
//       appTitle = (widget.conversation.conversationWith as User).name;
//     } else {
//       messageRequest = (MessagesRequestBuilder()
//         ..guid = (widget.conversation.conversationWith as Group).guid
//         ..limit = limit
//       )
//           .build();
//       appTitle = (widget.conversation.conversationWith as Group).name;
//     }
//
//
//     CometChat.addMessageListener("ConversationIdListener", this);
//
//     _loadMore();
//   }
//
//   //-----------Message Listeners------------------------------------------------
//   @override
//   void onTextMessageReceived(TextMessage textMessage) async {
//     User? user = await CometChat.getLoggedInUser();
//     if (user != null) {
//       if (textMessage.sender!.uid == user.uid) {
//         //await CometChat.markAsDelivered(textMessage, onSuccess: (_){}, onError: (_){});
//       }
//       //refreshSingleConversation(textMessage, false);
//     }
//   }
//
//   @override
//   void onMediaMessageReceived(MediaMessage mediaMessage) async {
//     User? user = await CometChat.getLoggedInUser();
//     if (user != null) {
//       if (mediaMessage.sender!.uid == user.uid) {
//         await CometChat.markAsDelivered(mediaMessage,
//             onSuccess: (_) {}, onError: (_) {});
//       }
//       //refreshSingleConversation(mediaMessage, false);
//     }
//   }
//
//   @override
//   void onCustomMessageReceived(CustomMessage customMessage) async {
//     User? user = await CometChat.getLoggedInUser();
//     if (user != null) {
//       if (customMessage.sender!.uid == user.uid) {
//         await CometChat.markAsDelivered(customMessage,
//             onSuccess: (_) {}, onError: (_) {});
//       }
//      // refreshSingleConversation(customMessage, false);
//     }
//   }
//
//   @override
//   void onMessagesDelivered(MessageReceipt messageReceipt) {
//     if (messageReceipt.receiverType == CometChatReceiverType.user) {
//      // setReceipts(messageReceipt);
//     }
//   }
//
//   @override
//   void onMessagesRead(MessageReceipt messageReceipt) {
//     if (messageReceipt.receiverType == CometChatReceiverType.user) {
//      // setReceipts(messageReceipt);
//     }
//   }
//
//   @override
//   void onMessageEdited(BaseMessage message) {
//     //refreshSingleConversation(message, true);
//   }
//
//   @override
//   void onMessageDeleted(BaseMessage message) {
//     //refreshSingleConversation(message, true);
//   }
//
//   @override
//   void onTypingStarted(TypingIndicator typingIndicator) {
//     setTypingIndicator(typingIndicator, true);
//   }
//
//   @override
//   void onTypingEnded(TypingIndicator typingIndicator) {
//     setTypingIndicator(typingIndicator, false);
//   }
//
//   //----------------Message Listeners end----------------------------------------------
//
//   setTypingIndicator(
//       TypingIndicator typingIndicator, bool isTypingStarted) async {
//     int matchingIndex = messageList.indexWhere((element) =>
//     ((element.conversationId!.contains(typingIndicator.receiverId) &&
//         element.conversationId!.contains(typingIndicator.sender.uid))));
//
//     if (isTypingStarted == true) {
//       _typingIndicatorMap[matchingIndex] = true;
//     } else {
//       _typingIndicatorMap.remove(matchingIndex);
//     }
//     setState(() {});
//   }
//
//   //Function to load more conversations
//   void _loadMore() {
//     isLoading = true;
//     itemFetcher
//         .fetch(messageRequest)
//         .then((List<BaseMessage> fetchedList) {
//       if (fetchedList.isEmpty) {
//         setState(() {
//           isLoading = false;
//           hasMoreItems = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           messageList.addAll(fetchedList);
//         });
//       }
//     });
//   }
//
//   FocusNode _focus = new FocusNode();
//   Widget getTypingIndicator(){
//     return Row(
//       children: const [
//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(
//             "Typing...",
//             style: TextStyle(color: Colors.black),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget getMessageComposer(){
//     return Form(
//       key: formKey,
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () async {
//             },
//             child: CircleAvatar(
//               backgroundColor: Colors.grey.withOpacity(0.5),
//               radius: 20
//               ,child: Icon(Icons.add),
//             ),
//           ),
//           Expanded(
//               child: Stack(
//                 children: [
//                   TextFormField(
//                     focusNode: _focus,
//                     controller: TextEditingController(text: messageText),
//                     onChanged: (val) {
//                       messageText = val;
//                     },
//                   ),
//                 ],
//               )), FloatingActionButton(
//               child: const Icon(Icons.attachment),
//               backgroundColor: Color(0xff131513),
//               heroTag: "dddd",
//               onPressed: () async {
//                 late String receiverID;
//                 String messageType = CometChatMessageType.image;
//                 String receiverType =
//                     widget.conversation.conversationType;
//                 String filePath = "";
//                 if (widget.conversation.conversationType == "user") {
//                   receiverID =
//                       (widget.conversation.conversationWith as User)
//                           .uid;
//                 } else {
//                   receiverID =
//                       (widget.conversation.conversationWith as Group)
//                           .guid;
//                 }
//
//                 FilePickerResult? result = await FilePicker.platform
//                     .pickFiles(type: FileType.media);
//                 //String messageType = CometChatMessageType.file;
//
//                 if (result != null &&
//                     result.files.single.path != null) {
//                   File file = File(result.files.single.path!);
//                   print(lookupMimeType(result.files.single.path!));
//                   filePath = result.files.single.path!;
//
//                   String? fileExtension =
//                   lookupMimeType(result.files.single.path!);
//                   if (fileExtension != null) {
//                     if (fileExtension.startsWith("audio")) {
//                       messageType = CometChatMessageType.audio;
//                     } else if (fileExtension.startsWith("image")) {
//                       messageType = CometChatMessageType.image;
//                     } else if (fileExtension.startsWith("video")) {
//                       messageType = CometChatMessageType.video;
//                     } else if (fileExtension
//                         .startsWith("application")) {
//                       messageType = CometChatMessageType.file;
//                     } else {
//                       messageType = CometChatMessageType.file;
//                     }
//                   }
//
//                   MediaMessage mediaMessage = MediaMessage(
//                       receiverType: receiverType,
//                       type: messageType,
//                       receiverUid: receiverID,
//                       file: filePath);
//
//                   // Map<String, dynamic> metadata = {};
//                   // metadata["lattitude"] = "50.6192171633316";
//                   // metadata["longitude"] = "-72.68182268750002";
//                   // mediaMessage.metadata = metadata;
//                   //
//                   // List<String> tags = [];
//                   // tags.add("pinned");
//                   // mediaMessage.tags = tags;
//                   //
//                   // mediaMessage.caption = "Message Caption";
//
//                   await CometChat.sendMediaMessage(mediaMessage,
//                       onSuccess: (MediaMessage message) {
//                         debugPrint(
//                             "Media message sent successfully: ${mediaMessage.metadata}");
//                         _messageList.insert(0, message);
//                         setState(() {});
//                       }, onError: (e) {
//                         debugPrint(
//                             "Media message sending failed with exception: ${e.message}");
//                       });
//                 } else {
//                   // User canceled the picker
//                 }
//               }),
//           FloatingActionButton(
//               child: const Icon(Icons.send),
//               backgroundColor: Color(0xff131513),
//               heroTag: "abbb",
//               onPressed: () {
//                 FocusScope.of(context).requestFocus(new FocusNode());
//
//                 late String receiverID;
//                 String messagesText = messageText;
//                 String receiverType = CometChatConversationType.user;
//                 String type = CometChatMessageType.text;
//
//                 if (widget.conversation.conversationType == "user") {
//                   receiverID =
//                       (widget.conversation.conversationWith as User).uid;
//                 } else {
//                   receiverID =
//                       (widget.conversation.conversationWith as Group)
//                           .guid;
//                 }
//                 TextMessage textMessage = TextMessage(
//                     text: messagesText,
//                     receiverUid: receiverID,
//                     receiverType: receiverType,
//                     type: type);
//
//                 textMessage.id = 46;
//
//                 CometChat.sendMessage(textMessage,
//                     onSuccess: (TextMessage message) {
//                       debugPrint("Message sent successfully:  ${message.text}");
//
//                       setState(() {
//                         _messageList.insert(0, message);
//                         messageText = "";
//                       });
//                     }, onError: (CometChatException e) {
//                       debugPrint(
//                           "Message sending failed with exception:  ${e.message}");
//                     });
//               }),
//
//
//
//           FloatingActionButton(
//               child: const Icon(Icons.link),
//               backgroundColor: Color(0xff131513),
//               onPressed: () async {
//                 late String receiverID;
//                 String messageType = CometChatMessageType.image;
//                 String receiverType =
//                     widget.conversation.conversationType;
//                 String filePath = "";
//                 if (widget.conversation.conversationType == "user") {
//                   receiverID =
//                       (widget.conversation.conversationWith as User)
//                           .uid;
//                 } else {
//                   receiverID =
//                       (widget.conversation.conversationWith as Group)
//                           .guid;
//                 }
//                 messageType = CometChatMessageType.image;
//
//
//
//                 MediaMessage mediaMessage = MediaMessage(
//                     receiverType: receiverType,
//                     type: messageType,
//                     receiverUid: receiverID,
//                     file: null);
//
//                 String fileUrl  = "https://pngimg.com/uploads/mario/mario_PNG125.png";
//                 String fileName   = "test";
//                 String fileExtension = "png";
//                 String fileMimeType = "image/png";
//
//                 Attachment attach =  Attachment(fileUrl,fileName,fileExtension,fileMimeType,null);
//                 mediaMessage.attachment= attach;
//
//                 await CometChat.sendMediaMessage(mediaMessage,
//                     onSuccess: (MediaMessage message) {
//                       debugPrint(
//                           "Media message sent successfully: ${mediaMessage.metadata}");
//                       _messageList.insert(0, message);
//                       setState(() {});
//                     }, onError: (CometChatException e) {
//                       debugPrint(
//                           "Media message sending failed with exception: ${e.message}");
//                     });
//
//                 String receiverId = "superhero2";
//                 Map<String,String> data= {};
//                 data["LIVE_REACTION"] =  "heart";
//
//                 TransientMessage transientMessage = TransientMessage( receiverId:receiverId , receiverType:  CometChatReceiverType.user , data: data, );
//
//                 CometChat.sendTransientMessage(transientMessage, onSuccess: (){
//                   debugPrint("Transient Message Sent");
//                 }, onError: (CometChatException e){
//
//                   debugPrint("Transient message sending failed with exception: ${e.message}");
//
//                 });
//
//
//               })
//
//
//         ],
//       ),
//     );
//   }
//
//
//   Widget getMessageWidget(int index){
//     return Text( (messageList[index] as TextMessage).text);
//
//     // if (_messageList[index] is MediaMessage) {
//     //   return ImageMessageWidget(
//     //       passedMessage: (_messageList[index] as MediaMessage),
//     //       readMessage: markRead);
//     // }
//     // var text;
//     // if (_messageList[index] is TextMessage) {
//     //   text = (_messageList[index] as TextMessage).text;
//     // } else if (_messageList[index] is c.Action) {
//     //   text = (_messageList[index] as c.Action).message;
//     // }
//     // return MessageWidget(
//     //   passedMessage: _messageList[index],
//     //   readMessage: markRead,
//     //   reinitiateList: reinitiateList,
//     // );
//
//   }
//
//   Widget getLoadingIndicator(){
//     return const Center(
//       child: SizedBox(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
//           strokeWidth: 1.0,
//         ),
//         height: 50,
//         width: 50,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chats"),
//       ),
//       body: Container(
//         padding: const EdgeInsets.only(left: 16.0, right: 16),
//         child: isLoading
//
//         //-----------loading widget -----------
//             ? getLoadingIndicator()
//
//         //----------- empty list widget-----------
//             : messageList.isEmpty
//             ? Center(
//           child: Text(
//             "No Chats yet",
//             style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w500,
//                 color: const Color(0xff141414).withOpacity(0.34)),
//           ),
//         )
//
//         //-----------list -----------
//             : ListView.builder(
//           padding: const EdgeInsets.all(0),
//           itemCount: hasMoreItems
//               ? messageList.length + 1
//               : messageList.length,
//           itemBuilder: (BuildContext context, int index) {
//             if (index >= messageList.length) {
//               _loadMore();
//               return getLoadingIndicator();
//             }
//
//             // if (messageList[index].conversationType ==
//             //     ConversationType.group ||
//             //     messageList[index].conversationWith is User) {
//             //   return getmessageListItem(
//             //       index, messageList[index]);
//             // }
//             if (isLoading) {
//               return getLoadingIndicator();
//             }
//
//             return Container();
//           },
//         ),
//       ),
//     );
//   }
// }
