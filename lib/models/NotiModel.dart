class NotiModel {

  String notiId;
  String notiText;
  String notiTitle;
  String type;
  int dateTime;

  NotiModel({this.notiId, this.notiTitle , this.notiText,this.type,this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'noti_id': notiId,
      'noti_title':notiTitle,
      'noti_text': notiText,
      'type':type,
      'date_time':dateTime,
    };
  }
}