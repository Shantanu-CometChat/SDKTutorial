import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/group/group_members.dart';
import 'package:sdk_tutorial/pages/group/update_group.dart';
import 'package:sdk_tutorial/pages/user_list.dart';

class MessageFunctions extends StatefulWidget {
  const MessageFunctions(
      {Key? key,
        required this.passedMessage,
        required this.sentByMe,
        required this.deleteMessage

      })
      : super(key: key);

  final BaseMessage passedMessage;
  final bool sentByMe;
  final Function(BaseMessage) deleteMessage;

  @override
  _MessageFunctionsState createState() => _MessageFunctionsState();
}

class _MessageFunctionsState extends State<MessageFunctions> {


  late String name;
  late Widget title;



  @override
  void initState() {
    super.initState();


    if(  widget.passedMessage.type==CometChatMessageType.text){
      title = Text((widget.passedMessage as TextMessage).text);
    }else{
      title= Text(widget.passedMessage.type);
    }

  }

  deleteMessage() async {
    widget.deleteMessage(widget.passedMessage);
    Navigator.of(context).pop();
  }




  @override
  Widget build(BuildContext context) {
    String? iconUrl  = widget.passedMessage.sender!.avatar;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Details"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
                child: SizedBox(
                    height: 72,
                    child: Center(
                      child: ListTile(
                        leading: CircleAvatar(
                            child:
                            iconUrl!=null&& iconUrl.trim()!=''?
                            Image.network(
                              iconUrl,
                            ):Center(
                              child: Text(widget.passedMessage.sender!.name),
                            )

                        ),
                        title: title ,
                        subtitle: Text(
                            "sent At :${widget.passedMessage.sentAt} "),
                      ),
                    )),
              ),
              if (widget.passedMessage.sender!.uid == USERID)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        onTap: deleteMessage,
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
