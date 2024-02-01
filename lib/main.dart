// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/LoginPage.dart';
import 'package:chatapp/pages/uplode_imagepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:uuid/uuid.dart';

import 'notificationservice/local_notification_service.dart';

var uuid = const Uuid();
var textColor = const [
  Color.fromARGB(255, 231, 102, 222),
  Color.fromARGB(255, 218, 120, 205),
  Color.fromARGB(255, 227, 137, 218),
];

var fCMtocken = "";
var serverKey =
    "AAAAsD7qhMA:APA91bGflnucgBrY06jjlTR9_ae_b0E6F6ke5DURaXJ6xQstlXW85TE_raOIhLP02kim5T8iU05tHPmhmHs0BbQ2lo1-0Sgg3TXyhGO-wHmGbKACOXHNpRW5fq0-mH4ym8e_ecngHpAU";

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
    }
  });
  // creating channel for user understanding
  var chats = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  var signup = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'signup/login',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Signup/Login',
  );
  var membership = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'membership',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Membership',
  );
  var request = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'request',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Request',
  );

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);

    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    // Not logged in
    runApp(const MyApp());
  }
}

LocalNotificationService localNotificationService = LocalNotificationService();

// Not Logged In
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    localNotificationService.initialiseNotification();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// Already Logged In
class MyAppLoggedIn extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<MyAppLoggedIn> createState() => _MyAppLoggedInState();
}

class _MyAppLoggedInState extends State<MyAppLoggedIn> {
  @override
  void initState() {
    super.initState();
    localNotificationService.initialiseNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
    );
  }
}
