import 'package:smart_call_app/db/entity/app_user.dart';
import 'package:smart_call_app/db/entity/chat.dart';

class ChatWithUser {
  Chat chat;
  AppUser user;

  ChatWithUser(this.chat, this.user);

  @override
  String toString() {
    return 'ChatWithUser(user: ${user.name}, lastMessage: ${chat.lastMessage?.text ?? 'No Message'}, timestamp: ${chat.lastMessage?.epochTimeMs ?? 'No Timestamp'})';
  }
}
