import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../db/Models/chat_with_user.dart';
import '../../../db/entity/utils.dart';

class ChatListTile extends StatefulWidget {
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
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {

  bool isMessageUnseen() {
    return widget.chatWithUser.chat.lastMessage?.seen == false &&
           widget.chatWithUser.chat.lastMessage?.senderId != widget.myUserId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isMessageUnseen()) {
          setState(() {
            widget.chatWithUser.chat.lastMessage?.seen = true;
          });
        }
        widget.onTap.call();
      },
      onLongPress: () {
        widget.onLongPress.call();
      },
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
                          widget.chatWithUser.user.profilePhotoPath,
                        ),
                      ),
                    ),
                    widget.chatWithUser.user.status == "online"
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

  Widget getTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.chatWithUser.user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            widget.chatWithUser.chat.lastMessage == null ? '' : convertEpochMsToDateTime(widget.chatWithUser.chat.lastMessage!.epochTimeMs),
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
            widget.chatWithUser.chat.lastMessage != null
                ? (isLastMessageMyText() ? "You: " : "") +
                  (widget.chatWithUser.chat.lastMessage!.type == "text"
                      ? widget.chatWithUser.chat.lastMessage!.text
                      : widget.chatWithUser.chat.lastMessage!.type)
                : "Say Hello 👋",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: isMessageUnseen() ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 40,
        child: widget.chatWithUser.chat.lastMessage != null && isMessageUnseen()
            ? Icon(Icons.circle, color: Colors.red, size: 20)
            : Container(),
      ),
    ],
  );
}




  bool isLastMessageMyText() {
    return widget.chatWithUser.chat.lastMessage?.senderId == widget.myUserId;
  }
}
