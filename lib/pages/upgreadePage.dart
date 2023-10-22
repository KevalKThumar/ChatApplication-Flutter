import 'package:flutter/material.dart';

class Membership extends StatelessWidget {
  const Membership({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("MemberShip"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Membership Page"),
        ));
  }
}
