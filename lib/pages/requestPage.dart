// ignore_for_file: use_build_context_synchronously, file_names, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/notificationModel.dart';

class RequestPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const RequestPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  _RequestPageState createState() => _RequestPageState();
}

List<Map<String, dynamic>> availableUser = [];
var isConnect = false;
late DateTime dateTime;
late String formattedDate;
late String formattedTime;

class _RequestPageState extends State<RequestPage> {
  @override
  void initState() {
    super.initState();
    getAllData();
    dateTime = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    formattedTime = DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<void> sendPushNotification(String tocken) async {
    try {
      final body = {
        "to": tocken,
        "notification": {
          "title": "Follow request",
          "body": "${widget.userModel.fullname} has send a request.",
          "android_channel_id": "request"
        }
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader: 'key=$serverKey',
              },
              body: jsonEncode(body));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } on Exception catch (e) {
      print('\n$e');
    }
  }

  void addNotification(String toUserId) {
    NotificationModel notification = NotificationModel(
      title: widget.userModel.fullname,
      message: "${widget.userModel.fullname!} has send a reqeust.",
      date: formattedDate,
      time: formattedTime,
      resiverId: toUserId,
      senderId: widget.userModel.uid,
    );
    print(notification);
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(uuid.v1())
        .set(notification.toMap())
        .then((value) => print('Notification stored successfully!'))
        .catchError((error) => print('Failed to store notification: $error'));
  }

  Future<List<Map<String, dynamic>>> getAllUsersListExceptMyAccount() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> usersDataCollection = [];

      for (var queryDocumentSnapshot in querySnapshot.docs) {
        if (widget.userModel.email != queryDocumentSnapshot.id) {
          usersDataCollection.add({
            queryDocumentSnapshot.id:
                '${queryDocumentSnapshot.get("fullname")}[user-name-about-divider]${queryDocumentSnapshot.get("tocken")}[user-name-about-divider]${queryDocumentSnapshot.get("uid")}',
          });
        }
      }

      // print(usersDataCollection);

      return usersDataCollection;
    } catch (e) {
      print('Error in get All Users List: ${e.toString()}');
      return [];
    }
  }

  Future<void> getAllData() async {
    final tackUser = await getAllUsersListExceptMyAccount();
    if (mounted) {
      availableUser = tackUser;
      // print("This is available user:::");
      // print(availableUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Request"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return connctionShowUp(index);
            },
            itemCount: availableUser.length,
          ),
        ),
      ),
    );
  }

  Widget connctionShowUp(int index) {
    var toUserTocken = availableUser[index]
        .values
        .first
        .toString()
        .split('[user-name-about-divider]')[1];
    print(toUserTocken);
    var toUserId = availableUser[index]
        .values
        .first
        .toString()
        .split('[user-name-about-divider]')[2];
    print(toUserId);
    return SizedBox(
      height: 80.0,
      width: double.maxFinite,
      //color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                availableUser[index]
                    .values
                    .first
                    .toString()
                    .split('[user-name-about-divider]')[0],
                style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), fontSize: 20.0),
              ),
              const Text(
                "user tocken",
                style: TextStyle(
                    color: Color.fromARGB(255, 71, 70, 70), fontSize: 16.0),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                if (isConnect == false) {
                  print("connect");
                  isConnect = true;
                  sendPushNotification(toUserTocken);
                  addNotification(toUserId);
                  print(
                      "push notificION IS SEND TO THIS TOCKEN:::$toUserTocken");
                } else {
                  print("disconnect");
                  isConnect = false;
                }
              });
            },
            child: isConnect == false
                ? const Text("connect")
                : const Text("cancel"),
          ),
        ],
      ),
    );
  }
}
