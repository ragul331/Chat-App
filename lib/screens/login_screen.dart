import 'package:couplet/screens/code_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacityAnimation;
  final numController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void login() async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: numController.text,
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            return;
          },
          codeSent: (String verificationId, int? token) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyScreen(
                          verificationId: verificationId,
                        )));
          },
          codeAutoRetrievalTimeout: (e) {
            return;
          });
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(
            flex: 1,
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: FadeTransition(
                opacity: opacityAnimation,
                child: Image.asset('assets/logo.png')),
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            'Welcome to Couplet',
            style: TextStyle(
                fontSize: 25, fontFamily: 'Lato', fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: TextField(
              keyboardType: TextInputType.phone,
              controller: numController,
              textAlign: TextAlign.center,
              scrollPhysics: const ScrollPhysics(),
              decoration: const InputDecoration(
                  hintText: "Mobile Number with +91",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: login,
            style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(Size(100, 50)),
            ),
            child: const Text('Verify Number',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700)),
          ),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
