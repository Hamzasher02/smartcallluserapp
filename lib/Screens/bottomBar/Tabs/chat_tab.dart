import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat/chat_screen.dart';
import '../../chat/widget/chats_list.dart';
import '../../../Widgets/chatting_list_view.dart';
import 'package:provider/provider.dart';
import '../../../db/Models/chat_with_user.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/entity/utils.dart';
import '../../../db/provider/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final AppUser user;

  const ChatScreen({required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Variables
  AnimationController? _animationController;
  AnimationController? controller2;

  @override
  void initState() {
    // controller2 = AnimationController(vsync: this);
    // _animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 250))
    //   ..forward();
    super.initState();
  }

  void chatWithUserPressed(ChatWithUser chatWithUser) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          chatId: compareAndCombineIds(myid, chatWithUser.user.id),
          myUserId: myid,
          otherUserId: chatWithUser.user.id,
          user: widget.user,
          otherUserName: chatWithUser.user.name,
        ),
      ),
    );
    // Navigator.pushNamed(context, ChatScreen.id, arguments: {
    //   "chat_id": chatWithUser.chat.id,
    //   "user_id": user.id,
    //   "other_user_id": chatWithUser.user.id
    // });
  }

  String myid = '';
  String myverificationstatus = '';

  Future<String?> userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // myverificationstatus = prefs.getString("myverificationstatus")!;
    myid = prefs.getString("myid")!;
    print(myid);
    return myid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: userId(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (snapshot.hasError) return Center(child: Text(snapshot.hasError.toString()));

          final myId = snapshot.data;
          // yCNNxSOczhe2t8FNQRTQjszOJSb2
          if (myId == null) return const Center(child: Text('MyId is null'));

          return Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return FutureBuilder<List<ChatWithUser>>(
                    future: userProvider.getChatsWithUser(myid),
                    builder: (context, chatWithUsersSnapshot) {
                      if (kDebugMode) {
                        print(chatWithUsersSnapshot.error);
                      }
                      if (chatWithUsersSnapshot.data == null && chatWithUsersSnapshot.connectionState != ConnectionState.done) {
                        if (kDebugMode) {
                          print(chatWithUsersSnapshot.data);
                          print(chatWithUsersSnapshot.error.toString());
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      } else {
                        return chatWithUsersSnapshot.data!.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_amber_outlined),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    // Lottie.asset('assets/lottie/no data found.json',width: 200),
                                    Text(
                                      'No Chats Found',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              )
                            : ChatsList(
                                chatWithUserList: chatWithUsersSnapshot.data!,
                                onChatWithUserTap: chatWithUserPressed,
                                myUserId: myId,
                              );
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
