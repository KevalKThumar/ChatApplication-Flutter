class NotificationModel {
  final String? title;
  final String? message;
  final String? senderId;
  final String? resiverId;
  final String? time;
  final String? date;

  NotificationModel({
    required this.title,
    required this.message,
    required this.resiverId,
    required this.time,
    required this.date,
    required this.senderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'senderId': senderId,
      'resiverId': resiverId,
      'date': date,
      'time': time,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'],
      message: map['message'],
      senderId: map['senderId'],
      resiverId: map['resiverId'],
      date: map['date'],
      time: map['time'],
    );
  }
}
