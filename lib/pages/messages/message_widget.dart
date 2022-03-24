import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:sdk_tutorial/constants.dart';

class MessageWidget extends StatefulWidget {
   TextMessage passedMessage;
   MessageWidget(
      {Key? key,
      required this.passedMessage,
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

              },
              child: Card(
                color: sentByMe==true?Colors.green: Colors.amberAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text ?? ""),
                ),
              ),
            ),
            // CometChatMessageReceipt(
            //   message: widget.passedMessage,
            //   loggedInUID: USERID,
            //   sentIcon: Text("Sent"),
            //   deliveredIcon: Text("delivered"),
            //   errorIcon: Text("error"),
            //   readIcon: Text("read"),
            // ),
            //
            // CometChatDate(
            //   date: DateTime.now(),
            //   isTransparentBackground: false,
            //
            // )


            // if (sentByMe == true)
            //   Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       if (widget.passedMessage.deliveredAt != null)
            //         Icon(Icons.check_outlined),
            //       if (widget.passedMessage.readAt != null)
            //         Icon(Icons.check_outlined)
            //     ],
            //   )
          ],
        ));
  }

}
