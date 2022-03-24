import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:sdk_tutorial/constants.dart';
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

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              
              onTap: () async {
                showMessageOptions(
                  context, widget.deleteFunction, widget.passedMessage
                );
              },
              child: Card(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text ?? ""),
                ),
              ),
            ),

            if (sentByMe == true)
            MessageReceipts(passedMessage: widget.passedMessage)
          ],
        ));
  }

}
