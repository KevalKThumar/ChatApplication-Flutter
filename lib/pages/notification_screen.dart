import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notificationModel.dart';

Stream<QuerySnapshot> getNotifications() {
  // Get a reference to the Firebase Firestore collection
  CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  // Return a stream of the notifications collection
  return notificationsCollection.snapshots();
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification App'),
      ),
      body: NotificationList(), // Display the notification list
    );
  }
}

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});
  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("resiverId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          // .orderBy("time", descending: true)
          .snapshots(), // Stream of notifications
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error retrieving notifications'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notifications found'));
        }
        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

        // Display the notification data in a ListView
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            NotificationModel notification = NotificationModel.fromMap(
                dataSnapshot.docs[index].data() as Map<String, dynamic>);

            return ListTile(
              title: Text(notification.message.toString()),
              subtitle: Text("${notification.date} ${notification.time}"),
              leading: const CircleAvatar(),
            );
          },
        );
      },
    );
  }
}
