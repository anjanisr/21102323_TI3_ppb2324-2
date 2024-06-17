import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:praktikum9/ui/home_screen.dart';

// ignore: use_key_in_widget_constructors
class PhoneAuthScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpVisibility = false;
  User? user;
  String verificationID = "";

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      // ignore: prefer_interpolation_to_compose_strings
      phoneNumber: "+62" + _phoneController.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          if (kDebugMode) {
            print("You are logged in successfully");
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print(e.message);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: _otpController.text);

    await auth.signInWithCredential(credential).then(
      (value) {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      },
    ).whenComplete(
      () {
        if (user != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Berhasil Login')));
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Login Gagal')));
        }
      },
    );
  }

  // ignore: annotate_overrides
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'Masukkan nomor telepon anda',
                prefix: Padding(padding: EdgeInsets.all(4), child: Text('+62')),
              ),
              keyboardType: TextInputType.phone,
            ),
            Visibility(
              visible: otpVisibility,
              child: TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  hintText: 'OTP',
                  prefix: Padding(padding: EdgeInsets.all(4), child: Text('')),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              color: const Color(0xff3D4DE0),
              onPressed: () {
                if (otpVisibility) {
                  verifyOTP();
                } else {
                  loginWithPhone();
                }
              },
              child: Text(otpVisibility ? "Verify" : "Login",
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
