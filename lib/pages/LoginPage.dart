// ignore_for_file: use_build_context_synchronously, file_names, library_private_types_in_public_api
import 'package:chatapp/models/UIHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  // Future<void> sendPushNotification(UserModel userModel) async {
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(userModel.uid)
  //       .update({
  //     "tocken": userModel.tocken,
  //   });
  //   try {
  //     final body = {
  //       "to": userModel.tocken,
  //       "data": {},
  //       "notification": {
  //         "title": userModel.fullname,
  //         "body": "You are loggin successfully",
  //         "android_channel_id": "signup/login"
  //       }
  //     };

  //     var response =
  //         await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //             headers: {
  //               HttpHeaders.contentTypeHeader: 'application/json',
  //               HttpHeaders.authorizationHeader: 'key=$serverKey',
  //             },
  //             body: jsonEncode(body));
  //     if (kDebugMode) {
  //       print('Response status: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //     }
  //   } on Exception catch (e) {
  //     log('Send notification is fail');
  //     log(e.toString());
  //   }
  // }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      // FirebaseMessaging fMessaging = FirebaseMessaging.instance;

      // await fMessaging.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );
      // fMessaging.getToken().then((tocken) {
      //   if (tocken != null) {
      //     userModel.tocken = tocken;
      //   }
      // });
      // FirebaseFirestore.instance.collection("users").doc(uid).update({
      //   "tocken": userModel.tocken,
      // });
      // Go to HomePage

      print("Log In Successful!");
      localNotificationService.sendNotification(
          "Login", "You are login in your account");
      print('Notification has been send');
      // print(userModel.tocken);

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: userModel, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        // You can customize other decoration properties here
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        )),
                      )
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      // You can customize other decoration properties here
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9, 
                    child: CupertinoButton(
                      onPressed: () {
                        checkValues();
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Text("Log In"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const SignUpPage();
                }),
              );
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
