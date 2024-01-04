import 'package:couplet/main.dart';
import 'package:couplet/screens/chat_screen.dart';
import 'package:couplet/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map? userMap = {};
  List<String> userList = [];
  final auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref('users');

  signout() async {
    auth.signOut();
    navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couplet-Users'),
        actions: [
          IconButton(onPressed: signout, icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {
            userList = [];
            if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
              userMap = snapshot.data?.snapshot.value as Map;
              userMap?.forEach((key, value) {
                userList.add(key);
              });
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    String key = userList[index];
                    String currentUser =
                        auth.currentUser?.phoneNumber as String;
                    if (currentUser == key) {
                      return Container();
                    }
                    return GestureDetector(
                      onTap: () {
                        navigatorKey.currentState?.push(MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  selectedNumber: key,
                                  name: userMap?[key]['name'],
                                )));
                      },
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/dp.png'),
                          radius: 30,
                        ),
                        title: Text(userMap?[key]['name']),
                        subtitle: Text(userMap?[key]['phoneNumber']),
                      ),
                    );
                  });
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return const LoginScreen();
          }),
    );
  }
}
