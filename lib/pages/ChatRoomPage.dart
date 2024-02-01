// ignore_for_file: file_names, library_private_types_in_public_api
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/MessageModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/upgreadePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/notificationModel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  late DateTime dateTime;
  late String formattedDate;
  late String formattedTime;
  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    formattedTime = DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<void> sendPushNotification(String msg) async {
    try {
      final body = {
        "to": widget.targetUser.tocken,
        "notification": {
          "title": widget.userModel.fullname,
          "body": msg,
          "android_channel_id": "chats"
        }
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader: 'key=$serverKey',
              },
              body: jsonEncode(body));
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('\n$e');
      }
    }
  }

  void addNotification(String msg) {
    NotificationModel notification = NotificationModel(
      title: widget.userModel.fullname,
      message: "${widget.userModel.fullname} send you $msg",
      date: formattedDate,
      time: formattedTime,
      resiverId: widget.targetUser.uid,
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

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      // FirebaseFirestore.instance.collection('users').doc(id).update({"":});

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap())
          .then((value) => sendPushNotification(msg));
      addNotification(msg);
      log("Message Sent!");
      log(widget.targetUser.tocken.toString());
      print(widget.userModel.tocken);
      // sendPushNotification(msg);
    }
  }

  void showPopUp(dynamic alignmentValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          backgroundColor: const Color.fromARGB(255, 193, 217, 237),
          alignment: Alignment(0.0, alignmentValue),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "To start chatting with your matches,",
                  style: TextStyle(
                    color: (Colors.black54),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Membership(),
                      ),
                    );
                  },
                  child: const Text(
                    "Upgrade Now!!",
                    style: TextStyle(
                      color: (Color.fromARGB(255, 13, 176, 204)),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
              // NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // This is where the chats will go
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    currentMessage.text.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              "An error occured! Please check your internet connection."),
                        );
                      } else {
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            10.heightBox,
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Enter message..."),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            )
                .box
                .color(Colors.grey.shade200)
                .roundedSM
                .padding(const EdgeInsets.symmetric(horizontal: 10))
                .make()
                .p(10),
          ],
        ),
      ),
    );
  }
}
