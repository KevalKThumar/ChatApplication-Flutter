// ignore_for_file: use_build_context_synchronously, file_names, library_private_types_in_public_api

import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/ChatRoomPage.dart';
import 'package:chatapp/pages/LoginPage.dart';
import 'package:chatapp/pages/SearchPage.dart';
import 'package:chatapp/pages/requestPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:velocity_x/velocity_x.dart';

import '../main.dart';
import 'acceptpage.dart';
import 'date.dart';
import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel get userModel => widget.userModel;
  bool isFabVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      drawer: Drawer(
        shape: const BeveledRectangleBorder(side: BorderSide.none),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              if (!isFabVisible) setState(() => isFabVisible == true);
            } else if (notification.direction == ScrollDirection.reverse) {
              if (isFabVisible) setState(() => isFabVisible == false);
            }
            return true;
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      maxRadius: 50,
                      backgroundImage: NetworkImage(
                          "https://i.ibb.co/23STBpw/05-12-21-happy-people.jpg"),
                    ),
                    6.heightBox,
                    "${userModel.fullname}".text.size(20).make()
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification Screen'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const NotificationPage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Accept Request'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AcceptPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser);
                    // SearchPage(
                    //     userModel: widget.userModel,
                    //     firebaseUser: widget.firebaseUser);
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Slide animation'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ScrolleAble();
                    // SearchPage(
                    //     userModel: widget.userModel,
                    //     firebaseUser: widget.firebaseUser);
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Send Request'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RequestPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser);
                    // SearchPage(
                    //     userModel: widget.userModel,
                    //     firebaseUser: widget.firebaseUser);
                  }));
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        "Confirm"
                            .text
                            .fontWeight(FontWeight.bold)
                            .color(const Color.fromARGB(255, 61, 61, 61))
                            .size(18)
                            .make(),
                        const Divider(),
                        10.heightBox,
                        "Are you sure you want to Logout!!"
                            .text
                            .color(const Color.fromARGB(255, 61, 61, 61))
                            .size(18)
                            .make(),
                        10.heightBox,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                localNotificationService.sendNotification(
                                    "Logout", "You are Logout..");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return const LoginPage();
                                  }),
                                );
                              },
                              child: "Yes".text.color(Vx.white).make(),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: "No".text.color(Vx.white).make(),
                            ),
                          ],
                        )
                      ],
                    )
                        .box
                        .color(Colors.white)
                        .padding(const EdgeInsets.all(12))
                        .roundedSM
                        .make(),
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>);

                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;

                    List<String> participantKeys = participants.keys.toList();
                    participantKeys.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future:
                          FirebaseHelper.getUserModelById(participantKeys[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: Colors.grey.withOpacity(0.2),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return ChatRoomPage(
                                          chatroom: chatRoomModel,
                                          firebaseUser: widget.firebaseUser,
                                          userModel: widget.userModel,
                                          targetUser: targetUser,
                                        );
                                      }),
                                    );
                                  },
                                  leading: const CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://i.ibb.co/23STBpw/05-12-21-happy-people.jpg'),
                                    // NetworkImage(
                                    //     targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          "")
                                      ? Text(
                                          chatRoomModel.lastMessage.toString())
                                      : Text(
                                          "Say hi to your new friend!",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text("No Chats"),
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
      floatingActionButton: FloatingActionButton(
        tooltip: "Search User",
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return
                // SearchPageRequest(
                //     userModel: widget.userModel, firebaseUser: widget.firebaseUser);
                SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
