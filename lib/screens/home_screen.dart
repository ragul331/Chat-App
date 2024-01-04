import 'package:couplet/main.dart';
import 'package:couplet/screens/login_screen.dart';
import 'package:couplet/screens/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool exist = false;
  final nameController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref('users');
  FirebaseAuth auth = FirebaseAuth.instance;

  save() async {
    String userNumber = auth.currentUser!.phoneNumber as String;
    Map<String, Object> userData = {
      userNumber: {
        'name': nameController.text,
        'phoneNumber': auth.currentUser!.phoneNumber,
        'chats': {
          '+91123456789': [
            ['+91123456789', 'Welcome to Couplet', false]
          ]
        }
      }
    };
    await ref.update(userData);
    navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const UserScreen()));
  }

  signout() async {
    auth.signOut();
    navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<bool> alreadyExist(String num) async {
    final snapshot = await ref.get();
    Map userMap = {};
    if (snapshot.exists && snapshot.value != null) {
      userMap = snapshot.value as Map;
    }

    if (userMap.isNotEmpty && userMap.containsKey(num)) {
      exist = true;
      return true;
    } else {
      exist = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String num = auth.currentUser!.phoneNumber.toString();
    return FutureBuilder<bool>(
      future: alreadyExist(num),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            exist = snapshot.data!;
            return !exist
                ? Scaffold(
                    appBar: AppBar(
                      title: const Text('Couplet-Home'),
                      actions: [
                        IconButton.outlined(
                            onPressed: signout, icon: const Icon(Icons.logout))
                      ],
                    ),
                    body: Column(
                      children: [
                        const Spacer(flex: 3),
                        Container(
                          height: 160,
                          width: 160,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/dp.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: TextField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            scrollPhysics: const ScrollPhysics(),
                            decoration: const InputDecoration(
                                hintText: "Profile Name",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: save,
                          style: const ButtonStyle(
                            minimumSize:
                                MaterialStatePropertyAll(Size(100, 50)),
                          ),
                          child: const Text('Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700)),
                        ),
                        const Spacer(flex: 5),
                      ],
                    ),
                  )
                : const UserScreen();
          }
        }
      },
    );
  }
}
