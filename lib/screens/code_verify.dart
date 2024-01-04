import 'package:couplet/main.dart';
import 'package:couplet/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyScreen extends StatefulWidget {
  final String verificationId;
  const VerifyScreen({super.key, required this.verificationId});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacityAnimation;
  final codeController = TextEditingController();
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

  void verify() async {
    final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: codeController.text);

    try {
      await auth.signInWithCredential(credential);
      navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
       e.toString();
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
              controller: codeController,
              textAlign: TextAlign.center,
              scrollPhysics: const ScrollPhysics(),
              decoration: const InputDecoration(
                  hintText: "Verification Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: verify,
            style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(Size(100, 50)),
            ),
            child: const Text('Next',
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
