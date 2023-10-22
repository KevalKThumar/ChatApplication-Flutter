import 'package:flutter/material.dart';

class ShowPopUp extends StatelessWidget {
  const ShowPopUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 183, 210, 224),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                Navigator.of(context).pop();
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
  }
}
