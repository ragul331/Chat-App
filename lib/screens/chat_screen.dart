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
  void send(Map currentUser, Map selectedUser) {
    if (msgController.text.trim().isNotEmpty) {
      List sUserList = currentUser['chats'][widget.selectedNumber] ?? [];

      List cUserList =
          selectedUser['chats'][auth.currentUser?.phoneNumber] ?? [];
      List selectedUserList = [];
      List currentUserList = [];
      for (var ch in sUserList) {
        selectedUserList.add(ch);
      }
      for (var ch in cUserList) {
        currentUserList.add(ch);
      }
      selectedUserList.add([currentUser['phoneNumber'], msgController.text]);
      currentUserList.add([currentUser['phoneNumber'], msgController.text]);
      Map chats = selectedUser['chats'];
      if (chats.containsKey(widget.selectedNumber)) {
        selectedUser['chats'][auth.currentUser?.phoneNumber] = selectedUserList;
        currentUser['chats'][widget.selectedNumber] = currentUserList;
        Map<String, Object?> sMap = {widget.selectedNumber: selectedUser};
        Map<String, Object?> cMap = {
          auth.currentUser?.phoneNumber as String: currentUser
        };
        ref.update(cMap);
        ref.update(sMap);
        msgController.clear();
      } else {
        selectedUser['chats'][auth.currentUser?.phoneNumber] = selectedUserList;
        currentUser['chats'][widget.selectedNumber] = currentUserList;
        Map<String, Object?> sMap = {widget.selectedNumber: selectedUser};
        Map<String, Object?> cMap = {
          auth.currentUser?.phoneNumber as String: currentUser
        };
        ref.update(cMap);
        ref.update(sMap);
        msgController.clear();
      }
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
              Map currentUser = userMap?[auth.currentUser?.phoneNumber];
              Map selectedUser = userMap?[widget.selectedNumber];
              List? chat = currentUser['chats'][widget.selectedNumber] ?? [];
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
                              send(currentUser, selectedUser);
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
