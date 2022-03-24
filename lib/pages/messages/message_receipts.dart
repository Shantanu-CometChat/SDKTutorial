import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class MessageReceipts extends StatelessWidget {
  final BaseMessage passedMessage;
  const MessageReceipts({Key? key,
  required this.passedMessage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget receiptIcon  = sentIcon();
    if(passedMessage.deliveredAt!=null)receiptIcon = deliveredIcon();
    if(passedMessage.readAt!=null)receiptIcon = readIcon();
    return SizedBox(
      child:receiptIcon ,

    );
  }

  Widget readIcon(){
    return Image.asset(
      "assets/read_icon.png",
      height: 14,
      width: 14,
    );
  }


  Widget deliveredIcon(){
    return Image.asset(
      "assets/delivered_icon.png",
      height: 14,
      width: 14,
    );
  }


  Widget sentIcon(){
    return  Image.asset(
      "assets/sent_icon.png",
      height: 14,
      width: 14,
    );
  }

}
