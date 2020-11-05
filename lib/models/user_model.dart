class UserModel {
  final String email;
  final String userName;
  final String password;
  final String uid;
  final String phoneNumber;
  final String token;
  final bool isAdmin;
  final String address;
  final String profileImage;
  final String isNewChat;
  final int finalChatDateTime;
  final String status;
  final String notiCount;
  final int messageNoti;
  final List<String> searchName;

  UserModel(
      { this.uid,
        this.userName,
        this.phoneNumber,
        this.address,
        this.email,
        this.password,
        this.isAdmin,
        this.profileImage,
        this.token,
        this.searchName,
        this.isNewChat,
        this.finalChatDateTime,
        this.status,
        this.notiCount,
        this.messageNoti
      });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'user_name': userName,
      'phone_number': phoneNumber,
      'address': address,
      'email': email,
      'password': password,
      'is_admin':isAdmin,
      'profile_image':profileImage,
      'token':token,
      'search_name':searchName,
      'is_new_chat':isNewChat,
      'final_chat_date_time':finalChatDateTime,
      'status':status,
      'noti_count':notiCount,
      'message_noti':messageNoti
    };
  }
}
