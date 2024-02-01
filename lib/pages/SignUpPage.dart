// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'dart:developer';
import 'package:chatapp/models/UIHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/uplode_imagepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // static Future<void> getInfo(UserModel userModel) async {
  //   await getFCMTocken(userModel);
  //   updateTocken(userModel);
  //   if (kDebugMode) {
  //     print(userModel.toString());
  //   }
  // }

  // static getFCMTocken(UserModel userModel) async {}

  // static void updateTocken(UserModel userModel) {

  // }

  // static sendNotificationAtSignin(UserModel newUser) async {}
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String tocken = "";
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();
    String name = nameController.text.trim();

    if (email == "" || password == "" || cPassword == "" || name == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The passwords you entered do not match!");
    } else {
      signUp(email, password, name);
    }
  }

  // Future<void> sendPushNotification(UserModel userModel) async {
  //   try {
  //     final body = {
  //       "to": userModel.tocken,
  //       "notification": {
  //         "title": userModel.fullname,
  //         "body": "You are succesfully signin",
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
  //     // if (kDebugMode) {
  //     log('Response status: ${response.statusCode}');
  //     log('Response body: ${response.body}');
  //     log('Response body: notification function');
  //   } on Exception catch (e) {
  //     // if (kDebu/gMode) {
  //     log('\n$e');
  //     // }
  //   }
  // }

  void signUp(String email, String password, String name) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Creating new account..");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }
    FirebaseMessaging fMessaging = FirebaseMessaging.instance;
    await fMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await fMessaging.getToken().then((value) {
      if (value != null) {
        tocken = value;
        log('THis is FCMtocken:---$tocken');
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: name,
        profilepic: "",
        tocken: tocken,
      );

      // for push notification

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) async {
        localNotificationService.sendNotification("Signup", "You are signup");
        // if (kDebugMode) {
        //   print("New User Created!");

        //   // print("This is pushTocken :: --${newUser.tocken}");
        // }

        Navigator.popUntil(context, (route) => route.isFirst);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return UplodeImage(
              userModel: newUser,
              firebaseUser: credential!.user!,
            );
          }),
        );
      });
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
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: "Email Address",
                        hintText: "Enter your email",
                        // You can customize other decoration properties here
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: "Full Name",
                        hintText: "Enter your full name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Confirm your password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
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
                      child: const Text("Sign Up"),
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
            "Already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Log In",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
