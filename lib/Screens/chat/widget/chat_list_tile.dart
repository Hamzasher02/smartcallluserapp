import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../db/Models/chat_with_user.dart';
import '../../../db/entity/utils.dart';

class ChatListTile extends StatelessWidget {
  final ChatWithUser chatWithUser;
  final VoidCallback onTap;
  final Function onLongPress;
  final String myUserId;

  const ChatListTile({
    super.key,
    required this.chatWithUser,
    required this.onTap,
    required this.onLongPress,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onTap.call();
      },
      onLongPress: () {},
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.085,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: CachedNetworkImageProvider(
                          chatWithUser.user.profilePhotoPath,
                        ),
                      ),
                    ),
                    chatWithUser.user.status == "online"
                        ? const Positioned(
                            right: 5,
                            bottom: 10,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: Color(0xFF39FF14),
                              ),
                            ),
                          )
                        : const Positioned(
                            right: 5,
                            bottom: 10,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getTopRow(),
                    getBottomRow(context),
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
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            chatWithUser.chat.lastMessage == null ? '' : convertEpochMsToDateTime(chatWithUser.chat.lastMessage!.epochTimeMs),
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget getBottomRow(BuildContext context) {
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
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14),
            ),
          ),
        ),
        SizedBox(
            width: 40,
            child: chatWithUser.chat.lastMessage == null || isLastMessageSeen() == false
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  )
                : null)
      ],
    );
  }
}
