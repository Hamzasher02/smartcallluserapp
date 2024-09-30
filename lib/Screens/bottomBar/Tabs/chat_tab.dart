import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat/chat_screen.dart';
import '../../chat/widget/chats_list.dart';
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
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  String? myid;
  String? myverificationstatus;

  @override
  void initState() {
    super.initState();
  }


 void chatWithUserPressed(ChatWithUser chatWithUser) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

  if (kDebugMode) {
    print("Image url of the user ${chatWithUser.user.profilePhotoPath}");
    print("Name of the user is ${chatWithUser.user.name}");
    print("Age of the user ${chatWithUser.user.age}");
    print("Country of the user is ${chatWithUser.user.country}");
    print("my id is $myid");
    print("Gender Of the user is ${chatWithUser.user.gender}");
  }
  
  if (myid != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          userType: chatWithUser.user.type,
          date: dateFormat.format(DateTime.now()),
          gender: chatWithUser.user.gender,
          age: chatWithUser.user.age,
          country: chatWithUser.user.country,
          image: chatWithUser.user.profilePhotoPath,
          chatId: compareAndCombineIds(myid ?? "", chatWithUser.user.id),
          myUserId: myid ?? "",
          otherUserId: chatWithUser.user.id,
          user: widget.user,
          otherUserName: chatWithUser.user.name,
          onChatClear: (chatId) {
            // Handle chat clear callback here, for example:
            setState(() {
              userProvider.removeChatWithUser(chatId);
            });
          },
        ),
      ),
    );
  } else {
    if (kDebugMode) {
      print("myid is null, cannot start chat");
    }
  }
}


  Future<String?> userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myid = prefs.getString("myid");
    myverificationstatus = prefs.getString("myverificationstatus");

    if (kDebugMode) {
      print("My user ID is $myid");
    }

    return myid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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

          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));

          final myId = snapshot.data;
          if (myId == null || myId.isEmpty) {
            return const Center(child: Text('Failed to retrieve user ID.'));
          }

          return Scaffold(
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return FutureBuilder<List<ChatWithUser>>(
                    future: userProvider.getChatsWithUser(myId),
                    builder: (context, chatWithUsersSnapshot) {
                      if (kDebugMode) {
                        print(chatWithUsersSnapshot.error);
                      }
                      if (chatWithUsersSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      }
                      if (chatWithUsersSnapshot.hasError ||
                          chatWithUsersSnapshot.data == null) {
                        return const Center(
                          child: Text('Failed to load chats.'),
                        );
                      }
                      return chatWithUsersSnapshot.data!.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning_amber_outlined),
                                  SizedBox(height: 10),
                                  Text('No Chats Found',
                                      style: TextStyle(fontSize: 20)),
                                ],
                              ),
                            )
                          : ChatsList(
                              chatWithUserList: chatWithUsersSnapshot.data!,
                              onChatWithUserTap: chatWithUserPressed,
                              myUserId: myId,
                            );
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
