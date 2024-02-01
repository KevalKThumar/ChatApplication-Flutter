// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chatapp/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:chatapp/models/UserModel.dart';

class UplodeImage extends StatefulWidget {
  const UplodeImage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  final UserModel userModel;
  final User firebaseUser;
  static String imageProfileLink = "";

  @override
  State<UplodeImage> createState() => _UplodeImageState();
}

class _UplodeImageState extends State<UplodeImage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 90,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: UplodeImage.imageProfileLink == ""
                    ? Icon(
                        Icons.upload_file_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          UplodeImage.imageProfileLink,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
              ),
              70.heightBox,
              SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    final ImagePicker imagePicker = ImagePicker();
                    UplodeImage.imageProfileLink = "";

                    final XFile? image = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      final croppedImage = await ImageCropper().cropImage(
                        sourcePath: image.path,
                        compressFormat: ImageCompressFormat.jpg,
                        compressQuality: 100,
                        uiSettings: [
                          AndroidUiSettings(
                              toolbarTitle: 'Cropper',
                              toolbarColor:
                                  Theme.of(context).colorScheme.secondary,
                              toolbarWidgetColor: Colors.white,
                              initAspectRatio: CropAspectRatioPreset.original,
                              lockAspectRatio: false),
                          IOSUiSettings(
                            title: 'Cropper',
                          ),
                        ],
                      );

                      if (croppedImage != null) {
                        String? currentUserUid = widget.userModel.uid;
                        UplodeImage.imageProfileLink = croppedImage.path;
                        var filename = basename(UplodeImage.imageProfileLink);
                        var destination = "images/${currentUserUid!}/$filename";
                        Reference ref =
                            FirebaseStorage.instance.ref().child(destination);
                        await ref.putFile(File(UplodeImage.imageProfileLink));
                        UplodeImage.imageProfileLink =
                            await ref.getDownloadURL();

                        var store = FirebaseFirestore.instance
                            .collection("users")
                            .doc(currentUserUid);
                        await store.set({
                          'profilepic': UplodeImage.imageProfileLink,
                        }, SetOptions(merge: true));

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: "Image Uploaded".text.makeCentered(),
                        ));
                        setState(() {});
                      }
                    }
                    if (image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: "No Image Selected".text.makeCentered(),
                      ));
                    }
                  },
                  child: "Add your Image".text.makeCentered(),
                ),
              ),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          userModel: widget.userModel,
                          firebaseUser: widget.firebaseUser,
                        ),
                      ),
                    );
                  },

                  child: "Submit".text.makeCentered(),
                ),


              )
            ],
          ),
        ),
      ),
    );
  }
}
