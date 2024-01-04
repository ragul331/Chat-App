import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String selectedNumber;
  const ChatScreen({
    super.key,
    required this.selectedNumber,
    required this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void send(Map currentuser, Map selectedUser) {
    List sUserList = currentuser['chats'][widget.selectedNumber] ?? [];
    List cuserList = selectedUser['chats'][auth.currentUser?.phoneNumber] ?? [];
    List selectedUserList = [];
    List currentuserList = [];
    for (var ch in sUserList) {
      selectedUserList.add(ch);
    }
    for (var ch in cuserList) {
      currentuserList.add(ch);
    }
    selectedUserList.add([currentuser['phoneNumber'], msgController.text]);
    currentuserList.add([currentuser['phoneNumber'], msgController.text]);
    Map chats = selectedUser['chats'];
    if (chats.containsKey(widget.selectedNumber)) {
      selectedUser['chats'][auth.currentUser?.phoneNumber] = selectedUserList;
      currentuser['chats'][widget.selectedNumber] = currentuserList;
      Map<String, Object?> sMap = {widget.selectedNumber: selectedUser};
      Map<String, Object?> cMap = {
        auth.currentUser?.phoneNumber as String: currentuser
      };
      ref.update(cMap);
      ref.update(sMap);
      msgController.clear();
    } else {
      selectedUser['chats'][auth.currentUser?.phoneNumber] = selectedUserList;
      currentuser['chats'][widget.selectedNumber] = currentuserList;
      Map<String, Object?> sMap = {widget.selectedNumber: selectedUser};
      Map<String, Object?> cMap = {
        auth.currentUser?.phoneNumber as String: currentuser
      };
      ref.update(cMap);
      ref.update(sMap);
      msgController.clear();
    }
  }

  Map? userMap = {};
  final msgController = TextEditingController();
  final auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref('users');
  @override
  Widget build(BuildContext context) {
    bool crtUser = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
              userMap = snapshot.data?.snapshot.value as Map;
              Map currentuser = userMap?[auth.currentUser?.phoneNumber];
              Map selectedUser = userMap?[widget.selectedNumber];
              List? chat = currentuser['chats'][widget.selectedNumber] ?? [];
              List? revChat = [];
              if (chat != null) {
                revChat = List.from(chat.reversed);
              }
              userMap?.forEach((key, value) {});
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: revChat.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          if (revChat?[index][0] == widget.selectedNumber) {
                            crtUser = true;
                          } else {
                            crtUser = false;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Align(
                              alignment: crtUser
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 23, vertical: 13),
                                decoration: BoxDecoration(
                                    color: !crtUser
                                        ? const Color.fromARGB(226, 84, 47, 101)
                                        : const Color.fromRGBO(
                                            72, 72, 72, 0.51),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30))),
                                child: Text(
                                  revChat?[index][1],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: msgController,
                            style: const TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                            )),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              send(currentuser, selectedUser);
                            },
                            icon: const Icon(Icons.send))
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
