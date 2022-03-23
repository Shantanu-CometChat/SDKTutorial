import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController guidTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController iconTextController = TextEditingController();
  TextEditingController decriptionTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  String? groupType = "public";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: guidTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'GUID',
                    hintText: 'GUID: A unique identifier for a group',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: nameTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Name: Name of the group',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: iconTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Icon',
                    hintText: 'Icon: An URL to group icon',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Group Type',
                    hintText: 'Group Type',
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: groupType,
                      items:
                          ["public", "private", "password"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        groupType = val;
                        print(groupType);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              if (groupType == CometChatGroupType.password)
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    controller: passwordTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Group Password',
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  maxLines: 5,
                  controller: decriptionTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    labelText: 'Description',
                    hintText: 'Description: Description about the group',
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String _GUID = guidTextController.text;
                      String _groupName = nameTextController.text;
                      String _groupType =
                          groupType ?? CometChatGroupType.public;
                      String _password = passwordTextController.text;

                      setState(() {
                        isLoading = true;
                      });
                      Group? group = await CometChat.createGroup(
                          _GUID, _groupName, _groupType,
                          password: _password,
                          onSuccess: (Group group) {},
                          onError: (CometChatException excep) {});
                      setState(() {
                        isLoading = false;
                      });

                      if (group == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Something Went Wrong"),
                        ));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Group Created"),
                      ));
                    }
                  },
                  child: Text("Create")),
              SizedBox(
                height: 10,
              ),
              if (isLoading) const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
