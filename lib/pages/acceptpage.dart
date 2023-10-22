import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';

class AcceptPage extends StatefulWidget {
  const AcceptPage(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<AcceptPage> createState() => _AcceptPageState();
}

class _AcceptPageState extends State<AcceptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accept Request"),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: const Center(
              child: Text("Accept Request"),
            )),
      ),
    );
  }
}
