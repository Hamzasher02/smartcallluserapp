import 'package:flutter/material.dart';
import '../../../db/Models/chat_with_user.dart';
import '../../../db/entity/utils.dart';

class ChatListTile extends StatelessWidget {
  final ChatWithUser chatWithUser;
  final void Function()? onTap;
  final Function onLongPress;
  final String myUserId;

  ChatListTile({required this.chatWithUser, required this.onTap, required this.onLongPress, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.085,
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(10),
        //   boxShadow: const [
        //     BoxShadow(
        //       offset: Offset(-0.5, 0.5),
        //       color: Colors.black87,
        //       spreadRadius: 0.2
        //     ),
        //   ],
        // ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2.0),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(chatWithUser.user.profilePhotoPath),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getTopRow(),
                    getBottomRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isLastMessageMyText() {
    return chatWithUser.chat.lastMessage?.senderId == myUserId;
  }

  bool isLastMessageSeen() {
    if (chatWithUser.chat.lastMessage?.seen == false && isLastMessageMyText() == false) {
      return false;
    }
    return true;
  }

  Widget getTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            chatWithUser.user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        Expanded(
          child: Text(
            chatWithUser.chat.lastMessage == null ? '' : convertEpochMsToDateTime(chatWithUser.chat.lastMessage!.epochTimeMs),
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12,color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget getBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Opacity(
            opacity: 0.6,
            child: Text(
              chatWithUser.chat.lastMessage == null
                  ? "Say Hello 👋"
                  : ((isLastMessageMyText() ? "You: " : "") + (chatWithUser.chat.lastMessage!.type == "text" ? chatWithUser.chat.lastMessage!.text : chatWithUser.chat.lastMessage!.type)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14,color: Colors.black),
            ),
          ),
        ),
        SizedBox(
            width: 40,
            child: chatWithUser.chat.lastMessage == null || isLastMessageSeen() == false
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xff00fff9), shape: BoxShape.circle),
                  )
                : null)
      ],
    );
  }
}
