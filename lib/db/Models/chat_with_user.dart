import '../entity/app_user.dart';
import '../entity/chat.dart';

class ChatWithUser {
  Chat chat;
  AppUser user;

  ChatWithUser(this.chat, this.user);
}
