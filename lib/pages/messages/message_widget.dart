import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/messages/message_functions.dart';
import 'package:sdk_tutorial/pages/messages/message_options.dart';
import 'package:sdk_tutorial/pages/messages/message_receipts.dart';

class MessageWidget extends StatefulWidget {
   TextMessage passedMessage;
   Function(BaseMessage msg) deleteFunction;
   MessageWidget(
      {Key? key,
      required this.passedMessage,
        required this.deleteFunction
      })
      : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  String? text;
  bool sentByMe = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (USERID == widget.passedMessage.sender!.uid) {
      sentByMe = true;
    } else {
      sentByMe = false;
    }

    text =widget.passedMessage.text;
    Color background = sentByMe==true?const Color(0xff3399FF).withOpacity(0.92) : const Color(0xffF8F8F8).withOpacity(0.92);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  MessageFunctions(
                            passedMessage: widget.passedMessage, sentByMe: sentByMe, deleteMessage: widget.deleteFunction)));
              },
              child: Card(
                color: background,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text ?? "",
                  style: TextStyle(color: const Color(0xffFFFFFF).withOpacity(0.92),),
                  ),
                ),
              ),
            ),

            if (sentByMe == true)
            MessageReceipts(passedMessage: widget.passedMessage)
          ],
        ));
  }

}
