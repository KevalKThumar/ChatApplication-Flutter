// ignore_for_file: file_names

class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? tocken;

  UserModel(
      {this.uid, this.fullname, this.email, this.profilepic, this.tocken});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    tocken = map["tocken"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "tocken": tocken,
    };
  }
}
