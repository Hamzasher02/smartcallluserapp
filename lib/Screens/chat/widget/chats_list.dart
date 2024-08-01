import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:smart_call_app/db/remote/firebase_database_source.dart';
import '../../../db/Models/chat_with_user.dart';
import '../../../db/Models/chats_observer.dart';
import 'chat_list_tile.dart';

class ChatsList extends StatefulWidget {
  final List<ChatWithUser> chatWithUserList;
  final Function(ChatWithUser) onChatWithUserTap;
  final String myUserId;

  ChatsList({
    required this.chatWithUserList,
    required this.onChatWithUserTap,
    required this.myUserId,
  });

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  ChatsObserver? _chatsObserver;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  @override
  void initState() {
    super.initState();
    _chatsObserver = ChatsObserver(widget.chatWithUserList);
    _chatsObserver!.startObservers(chatUpdated);
    userId();
  }

  @mustCallSuper
  @protected
  void dispose() {
    // _chatsObserver.removeObservers();
    super.dispose();
  }

  void chatUpdated() {
    setState(() {});
  }

  bool changeMessageSeen(int index) {
    return widget.chatWithUserList[index].chat.lastMessage?.seen == false && widget.chatWithUserList[index].chat.lastMessage?.senderId != widget.myUserId;
  }

  String myid = '';
  String myverificationstatus = '';
  bool value = false;

  Future<String?> userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // myverificationstatus = prefs.getString("myverificationstatus")!;
    return myid = prefs.getString("myid")!;
  }

  @override
  Widget build(BuildContext context) {
    widget.chatWithUserList.sort((a, b) {
      final aTimestamp = a.chat.lastMessage?.epochTimeMs ?? 0;
      final bTimestamp = b.chat.lastMessage?.epochTimeMs ?? 0;
      return bTimestamp.compareTo(aTimestamp);
    });

    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.grey),
      itemCount: widget.chatWithUserList.length,
      itemBuilder: (BuildContext _, int index) {
        return ChatListTile(
          chatWithUser: widget.chatWithUserList[index],
          onTap: () {
            //if(myverificationstatus.compareTo('Verified')==0) {
            if (widget.chatWithUserList[index].chat.lastMessage != null && changeMessageSeen(index)) {
              widget.chatWithUserList[index].chat.lastMessage?.seen = true;
              chatUpdated();
            }
            widget.onChatWithUserTap(widget.chatWithUserList[index]);
            // }
            // else
            //   {
            //     //showPaymentWarningDialog(context);
            //     showSwpipDialog(context);
            //   }
          },
          onLongPress: () {},
          myUserId: widget.myUserId,
        );
      },
    );
  }

  Future _refresh() async {
    setState(() {});
  }
}
