import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/dashboard.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List<MaterialButtonUserModel> userModelList = [
    MaterialButtonUserModel("superhero1", "SUPERHERO1", "assets/captainamerica_avatar.png"),
    MaterialButtonUserModel("superhero2", "SUPERHERO2", "assets/cyclops_avatar.png"),
    MaterialButtonUserModel("superhero3", "SUPERHERO3", "assets/ironman_avatar.png"),
    MaterialButtonUserModel("superhero4", "SUPERHERO4", "assets/spiderman_avatar.png"),
  ];

  @override
  void initState() {
    super.initState();

    AppSettings appSettings = (AppSettingsBuilder()
          ..subscriptionType = CometChatSubscriptionType.allUsers
          ..region = CometChatAuthConstants.region
          ..autoEstablishSocketConnection = true)
        .build();

    CometChat.init(CometChatAuthConstants.appId, appSettings,
        onSuccess: (String successMessage) {
      debugPrint("Initialization completed successfully  $successMessage");
    }, onError: (CometChatException excep) {
      debugPrint("Initialization failed with exception: ${excep.message}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/cometchat_logo.png",
               height: 100, width:100),
              const Text("CometChat",style: TextStyle(color: Colors.black54, fontSize: 30, fontWeight: FontWeight.bold),),
              const Text("Push Notification",style: TextStyle(color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold),),
              const Text("Sample App",style: TextStyle(color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold),),
              const SizedBox(
                height: 20.0,
              ),
              Wrap(
                children: const [Text("Login with one of our sample user",style: TextStyle(color: Colors.black38, fontSize: 30),)],
              ),
              const SizedBox(
                height: 20.0,
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 3.0,

                children: List.generate(userModelList.length,
                    (index) => userSelectionButton(userModelList[index])),
              )
            ],
          )),
        ),
      )),
    );
  }

  Widget userSelectionButton(MaterialButtonUserModel model) {
    return MaterialButton(
        color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0) ),
        onPressed : (){
          loginUser(model);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(model.imageURL,
              height: 30,
                width: 30,
              ),
            ),
            Text(model.userId, style: const TextStyle(color: Colors.white, fontSize: 14.0 ),)
          ],
        ),
      );
  }

  loginUser(MaterialButtonUserModel model) async {
    var  user = await CometChat.getLoggedInUser();
    if (user == null) {
      await CometChat.login(model.userId, CometChatAuthConstants.authKey,
          onSuccess: (User loggedInUser) {
            debugPrint("Login Successful : $loggedInUser" );
            user = loggedInUser;
          }, onError: (CometChatException e) {
            debugPrint("Login failed with exception:  ${e.message}");
          }
      );
    }

    if(user!=null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>
      const DashBoard()
      ));
    }
  }
}

class MaterialButtonUserModel {
  String username;
  String userId;
  String imageURL;

  MaterialButtonUserModel(this.username, this.userId, this.imageURL);
}
