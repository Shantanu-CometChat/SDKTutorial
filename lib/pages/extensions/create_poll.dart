
import 'package:flutter/material.dart';

class CreatePoll extends StatefulWidget {
  const CreatePoll({Key? key}) : super(key: key);

  @override
  _CreatePollState createState() => _CreatePollState();
}

class _CreatePollState extends State<CreatePoll> {
  String _question="";
  List<String> _answers = [""];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.of(context).pop();

                }, icon: const  Icon(Icons.arrow_back))

              ],
            )

          ],

        ),


      ),

    );
  }
}
