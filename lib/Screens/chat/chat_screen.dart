import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Screens/call/agora/video_call_screen_1.dart';
import 'package:smart_call_app/Screens/chat/widget/chat_top_bar.dart';
import 'package:smart_call_app/Screens/chat/widget/message_bubble.dart';
import 'package:smart_call_app/Util/video_call_fcm.dart';
import 'package:smart_call_app/Widgets/country_to_flag.dart';
import 'package:smart_call_app/db/Models/chat_with_user.dart';
import 'package:smart_call_app/db/entity/sentmessage.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../../db/entity/app_user.dart';
import '../../db/entity/chat.dart';
import '../../db/entity/message.dart';
import '../../db/remote/firebase_database_source.dart';

class MessageScreen extends StatefulWidget {
  final AppUser user;
  final Function(String)? onChatClear; // Accept the callback

  MessageScreen(
      {required this.chatId,
      required this.myUserId,
      required this.otherUserId,
      this.onChatClear,
      this.age,
      this.otherUserDeviceToken,
      this.country,
      this.gender,
      this.image,
      this.userType,
      this.date,
      required this.user,
      required this.otherUserName});

  /// Get user object
  final String chatId;
  String? gender;
  String? country;
  String? age;
  String? image;
  String? otherUserDeviceToken;
  String? date;
  String? userType;
  final String myUserId;
  final String otherUserId;
  final String otherUserName;

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<ChatWithUser> chatWithUserList = [];
  Set<String> selectedMessageIds = {}; // To store selected message IDs
  bool isSelectionMode = false; // Flag to track selection mod

  void handleChatClear() {
    widget.onChatClear?.call(widget.chatId);
  }

  void toggleSelection(String messageId) {
    setState(() {
      if (selectedMessageIds.contains(messageId)) {
        selectedMessageIds.remove(messageId);
      } else {
        selectedMessageIds.add(messageId);
      }
    });
  }

  void toggleMessageSelection(String messageId) {
    setState(() {
      if (selectedMessageIds.contains(messageId)) {
        selectedMessageIds.remove(messageId); // Unselect if already selected
      } else {
        selectedMessageIds.add(messageId); // Select if not selected
      }
    });
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode)
        selectedMessageIds.clear(); // Clear selection if mode is disabled
    });
  }

  Future<void> deleteSelectedMessages() async {
    try {
      for (String messageId in selectedMessageIds) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .doc(messageId)
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected messages deleted successfully.'),
        ),
      );

      // Exit selection mode after deletion
      toggleSelectionMode();
    } catch (e) {
      print('Error deleting messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete selected messages.'),
        ),
      );
    }
  }

  // Confirmation dialog for deleting selected messages
  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete selected messages?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Clear selected messages when Cancel is tapped
                setState(() {
                  selectedMessageIds.clear();
                  isSelectionMode = false;
                });
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                deleteSelectedMessages(); // Proceed to delete selected messages
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  dynamic _clearChat(BuildContext context) async {
    try {
      // Delete all messages in the chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      // Delete the chat document itself
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .delete();

      // Remove chat from UI
      handleChatClear();

      // Show confirmation (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat cleared successfully.'),
        ),
      );
    } catch (e) {
      // Handle any errors here
      print("Error clearing chat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear chat.'),
        ),
      );
    }
  }

  void _startCall(String callType) {
    _databaseSource.storeCallInfo(
      chatId: widget.chatId,
      myUserId: widget.myUserId,
      otherUserId: widget.otherUserId,
      callType: callType,
      callStatus: "Started",
      isIncoming: false,
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(context, messageId); // Delete the message
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete the message from Firestore
  Future<void> _deleteMessage(BuildContext context, String messageID) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageID)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted successfully.'),
        ),
      );
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete message.'),
        ),
      );
    }
  }

  void _endCall(String callType, {String status = "Ended"}) {
    _databaseSource.storeCallInfo(
      chatId: widget.chatId,
      myUserId: widget.myUserId,
      otherUserId: widget.otherUserId,
      callType: callType,
      callStatus: status,
      isIncoming: false,
      callDuration: calculateCallDuration(),
    );
  }

  int calculateCallDuration() {
    // Implement logic to calculate the call duration
    return 0;
  }

  // late ZegoUIKitPrebuiltCallInvitationService _callInvitationService;

  @override
  void initState() {
    //dataFireBase();
    super.initState();
    markMessagesAsRead();
    if (kDebugMode) {
      print('The age of the user is ${widget.age}');
      print('The country of the user is ${widget.country}');
      print('The gender of the user is ${widget.gender}');
      print('The image of the user is ${widget.image}');
      print('The name of the user is ${widget.otherUserName}');
      print('The type of the user is ${widget.userType}');
      print('The date of the user is ${widget.date}');
    }

    // initZego();
  }

  void chatBuddySent(String myid, String otherid, String sent) async {
    _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
  }

  void chatBuddyReceived(String otherid, String myid, String received) async {
    //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
    _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
  }

  void markMessagesAsRead() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .where('sender_id', isNotEqualTo: widget.myUserId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .doc(doc.id)
            .update({'seen': true});
      }
    });
  }

  void showUserView({
    required BuildContext context,
    required String type,
    required String id,
    required String img,
    required String name,
    required String country,
    required String date,
    required String age,
    required String gender,
    required String myid,
    required String otherId,
  }) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Name and Favorite Icon
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Country
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(countryCodeToEmoji(country)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    Country.tryParse(country)!.name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),

                            /// Age
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Age: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$age",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// Gender
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Gender: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$gender",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// Buttons
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      String chatId = compareAndCombineIds(
                                        myid,
                                        id,
                                      );
                                      Message1 message = Message1(
                                        epochTimeMs: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        seen: false,
                                        senderId: myid,
                                        text: "Say Hello 👋",
                                        type: "text",
                                      );
                                      _databaseSource
                                          .addChat(Chat(chatId, message));
                                      chatBuddySent(myid, id, "Buddy Sent");
                                      chatBuddyReceived(
                                          id, myid, "Buddy received");
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            gender: gender,
                                            age: age,
                                            image: img,
                                            country: country,
                                            chatId:
                                                compareAndCombineIds(myid, id),
                                            myUserId: myid,
                                            otherUserId: id,
                                            otherUserName: name,
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.7),
                                      radius: 30,
                                      child: const Icon(
                                        Icons.chat,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // type == "live"
                                  //     ? SizedBox(
                                  //         width: 90.0, // Set your desired width
                                  //         height:
                                  //             90.0, // Set your desired height
                                  //         child: FittedBox(
                                  //           fit: BoxFit.cover,
                                  //           child: ZegoSendCallInvitationButton(
                                  //             isVideoCall: true,
                                  //             resourceID: "zegouikit_call",
                                  //             invitees: [
                                  //               ZegoUIKitUser(
                                  //                 id: id,
                                  //                 name: name,
                                  //               ),
                                  //             ],
                                  //             icon: ButtonIcon(
                                  //                 icon: const Icon(
                                  //                   Icons.videocam_rounded,
                                  //                   size: 50,
                                  //                   color: Colors.white,
                                  //                 ),
                                  //                 backgroundColor:
                                  //                     Colors.green),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : type == "fake"
                                  //         ? GestureDetector(
                                  //             onTap: () {
                                  //               Navigator.push(
                                  //                   context,
                                  //                   MaterialPageRoute(
                                  //                       builder: (context) =>
                                  //                           DummyWaitingCallScreen(
                                  //                             userImage: img,
                                  //                             userName: name,
                                  //                           )));
                                  //             },
                                  //             child: const Align(
                                  //               alignment:
                                  //                   Alignment.centerRight,
                                  //               child: CircleAvatar(
                                  //                 backgroundColor: Colors.green,
                                  //                 radius: 30,
                                  //                 child: Icon(
                                  //                   Icons.videocam_rounded,
                                  //                   size: 40,
                                  //                   color: Colors.white,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           )
                                  //         : Container(),
                                ],
                              ),
                            ),

                            /// Date
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
  }

  // void initZego() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedUserId = prefs.getString('userId');
  //   String? storedUserName = prefs.getString('userName');

  //   if (kDebugMode) {
  //     print(
  //         "Id of the current tapped is ${storedUserId ?? "default current user"}");
  //     print("Name of the current user is $storedUserName");
  //   }

  //   // Ensure userID and userName are not null before passing them to Zego
  //   await ZegoUIKitPrebuiltCallInvitationService().init(
  //     appID: Utils.appId,
  //     appSign: Utils.appSignin,
  //     userID: storedUserId ?? "defaultUserId",
  //     userName: storedUserName ?? "defaultUserName",
  //     notifyWhenAppRunningInBackgroundOrQuit: true,
  //     androidNotificationConfig: ZegoAndroidNotificationConfig(
  //       channelID: "ZegoUIKit",
  //       channelName: "Call Notifications",
  //       sound: "notification",
  //       icon: "notification_icon",
  //     ),
  //     iOSNotificationConfig: ZegoIOSNotificationConfig(
  //       isSandboxEnvironment: false,
  //       systemCallingIconName: 'CallKitIcon',
  //     ),
  //     plugins: [ZegoUIKitSignalingPlugin()],
  //     requireConfig: (ZegoCallInvitationData data) {
  //       final config = (data.invitees.length > 1)
  //           ? ZegoCallType.videoCall == data.type
  //               ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
  //               : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
  //           : ZegoCallType.videoCall == data.type
  //               ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  //               : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

  //       config.topMenuBarConfig.isVisible = true;

  //       config.topMenuBarConfig.buttons
  //           .insert(0, ZegoMenuBarButtonName.minimizingButton);

  //       return config;
  //     },
  //   );
  // }

  // void _uninitializeCallInvitationService() {
  //   _callInvitationService.uninit();
  // }

  @override
  void dispose() {
    super.dispose();
    // _uninitializeCallInvitationService();
  }

  String generateCallId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Variables
  final _textController = TextEditingController();
  bool _isComposing = false;
  final ScrollController _scrollController = new ScrollController();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
        Navigator.pop(context);
      }
    });
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "smart-call-app",
      "private_key_id": "a6097eab06502ca4adeed426d6f0e7beb27b2eb8",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCSvvNuMvaJzVbD\nsnGJ7Eu6axS7WO0G4ZKeGXlDufrpx9rLrthbXuHKn/DxHZcRwVBL4YOi3YbAFK2N\njtAjzP/fs/lLuDyYX/3nDzpzWzFMu6970nrnupBfXFNOamold1EiQhTnS5nEXzAB\nxvZpYhaqF8Av+LQxNMtMUL0aG2+ScF2CXWWs3NAGNNgzTR4ZAvZx2uVWPf8op5L0\nINZiUz3ZcMziU9EQ4GjPqPYiP9TBDnrNLkjxaeW8/Z6kh5uFPU4TuHlWB4p0xQ9l\nnb/p/F6qkszh9Q/acrUYGWXz2sRJKwnJVvdCj+K/NKYCVM2XzcfcjHyBkZiyzdHe\n4bAj6NChAgMBAAECggEAFDIid4KdCocPj1xSIuy52VyeXFBXQrCtyINx/H+uiBkg\nxBJ6pUyQH55WfyCW53Mm9WKChtodDvdpkUdb3ul6N5Ph1elzsXbYj0G5xiGBTfGw\nq4ZistyqvO0MbAjaNfDPYjsc/F4bufpttXjn9cXxn5QoN5HvXqxI5GZiOCMZfloy\nMpYK/010LL8nYXq6xR2m/mqFsLdmqmrk9FO1ksIzH7oIa4pnwWLj6jyc0ThPE/Ml\nV8xhFIawAZ7u/BxwoJBetBdQXnYLa707q3xVJ2PT94AAjhSxSpeDoLrp5okY58tz\n5XOKj+UTN2u8UchaSRO2u484GPXGmoKXQ9YyKAddzwKBgQDCtEI297Qvk2dNE7bq\ng7FXiy4OiJl8o/ofQrNoiGwGMZ7ipIjzPwjSRJZu3gGk2TEUa2PAAh/9DcGOQQHr\nCu1L/Rf7ad1qxQbxn5b9RXfqqjUDZJ+SMFFDGyQdY7Y735DLFzGvxJmos7d97Wyc\nBBsNbo3TpzN8dARmzt7x2hkBDwKBgQDA8Zs+c0wmDjRUJE8xyQyIk3ETZOSLjJg9\nQzKYFf8P+nAz2bgY0c9DZ+76Kl5HoGPl/knV+6CwWYxXma3UjWoR/4XQI95YO0Ew\n+4rZwRXZThgMcU6GyBgoZfzxcWsQ8AOVMhViakKaIq3a2eTbUrrHu8eT+OWmu1Nd\noBHJVkyzTwKBgCGnhsp5hmuyzuhDwBpJKR44sH1SnzUsIs/Ed75Z1lI7wXrrdcCV\n5LBzqoz/UslrwVAGP/ewZlcXSZ2NHwfBm8LGvJ54bg1GgSzCqRaeK1wkj4VGn05l\ni6ZNyrBJy/YNbrmsCKqZEPZYGh9qKpvNGd/4fAtZm0ynwRsEJwUm7auBAoGBAKNu\nxFqE3XbKx2aSjwaTz2sMwVZ1OuY+BGK4Pe33i+Mj9tDk1f0oE5F8Q0BijRPM93HF\nERQRnc5jO+6j/UuzMarnL5jcGSXRo2nzWG0VEgXNEa/QdnzSlyv5H+YAdXmWZOKG\n1vhTG/Fl+LANq75f+FjhZa+gwB6YRIhk40wRLs0fAoGBALMEE4mLeu7NFjNMd+di\nkbn08patjnWAJAAGWgU8ZTl6gZCCgwJZd2BODgTkL2mo1y3/0tPlXGiVUUKjtATt\n3/l9YMiC6QXrAms+i4a1cUNSz1ObziYIq4g49yAmHeFAsDG8RssNZzKLYc8GiPfS\nEPBJ/1A+O7iAtlp7Hwz6t90a\n-----END PRIVATE KEY-----\n",
      "client_email": "smart-call-app@appspot.gserviceaccount.com",
      "client_id": "100437911684667732755",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/smart-call-app%40appspot.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    return credentials.accessToken.data;
  }

  void sendFCMMessage(String sendMessage) async {
    if (kDebugMode) {
      print('Title of the notification: ${widget.user.name}');
      print('Body of the notification: $sendMessage'); // Double-check here
      print('Picture of the notification: ${widget.user.profilePhotoPath}');
      print(
          'Token of the Receiver device: ${widget.otherUserDeviceToken ?? ""}');
    }

    final String serverKey = await getAccessToken();
    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/smart-call-app/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': widget.otherUserDeviceToken.toString(),
        'notification': {
          'body': sendMessage, // Body of the notification
          'title': widget.otherUserName.toString(),
          'image': widget.image ?? "", // Add the image URL here
        },
        'data': {
          'image': widget.image ?? "",
          'navigate': 'chat_screen', // Navigate to chat screen
          "chat_id": widget.chatId,
          "otheruser_name": widget.otherUserName,
          "otheruser_id": widget.otherUserId,
          "myuser_id": widget.myUserId,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully.');
    } else {
      print('Failed to send FCM message: ${response.body}');
    }
  }

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future getFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
      uploadFile();
      Navigator.pop(context);
    }
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();

    var ref = FirebaseStorage.instance
        .ref()
        .child("users/${widget.myUserId}/images/$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!);

    String ImageUrl = await uploadTask.ref.getDownloadURL();
    sendMessage(widget.myUserId, ImageUrl, 'img');
    print(ImageUrl);
  }

  Future uploadFile() async {
    final path = 'users/${widget.myUserId}/files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
    var uploadDocTask = await ref.putFile(file);
    String docUrl = await uploadDocTask.ref.getDownloadURL();
    sendMessage(widget.myUserId, docUrl, 'doc');
  }

  Future _showMultiIcon() {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.5),
              title: const Text(
                'Select Media',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              content: Container(
                height: 40,
                width: 20,
                decoration: BoxDecoration(
                  //  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                //height: 20.h,
                // width: 50.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => getImage(),
                      child: const Icon(
                        Icons.image,
                        size: 50,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () => getFile(),
                      child: const Icon(
                        Icons.document_scanner,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  showProfileDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              //backgroundColor: Colors.black,
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              content: Container(
                decoration: BoxDecoration(
                  //  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                //height: 20.h,
                // width: 50.w,
                child: const Column(
                  children: [],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? myid;

  void unmatch() async {
    print('done');
  }

  void checkAndUpdateLastMessageSeen(
      Message1 lastMessage, String messageId, String myUserId) {
    if (lastMessage.seen == false && lastMessage.senderId != myUserId) {
      lastMessage.seen = true;
      Chat updatedChat = Chat(widget.chatId, lastMessage);

      _databaseSource.updateChat(updatedChat);
      _databaseSource.updateMessage(widget.chatId, messageId, lastMessage);
    }
  }

  bool shouldShowTime(Message currMessage, Message messageBefore) {
    int halfHourInMilli = 1800000;

    if (messageBefore != null) {
      if ((messageBefore.epochTimeMs - currMessage.epochTimeMs).abs() >
          halfHourInMilli) {
        return true;
      }
    }
    return messageBefore == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _databaseSource.observeUser(widget.otherUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                showUserView(
                  context: context,
                  type: widget.userType!,
                  id: widget.otherUserId,
                  img: widget.image!,
                  name: widget.otherUserName,
                  country: widget.country!,
                  date: widget.date!,
                  age: widget.age!,
                  gender: widget.gender!,
                  myid: widget.myUserId,
                  otherId: widget.otherUserId,
                );
              },
              child: ChatTopBar(user: AppUser.fromSnapshot(snapshot.data!)),
            );
          },
        ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDeleteConfirmationDialog(); // Show dialog to confirm deletion
              },
            ),
          ThreeDotMenu(
            chatId: widget.chatId,
            onChatClear: () => _clearChat(context),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            if (isSelectionMode) {
              exitSelectionMode(); // Cancel selection if in selection mode
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MainPage(tab: 2),
              ));
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _databaseSource.observeMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                List<Message1> messages = [];
                snapshot.data?.docs.forEach((element) {
                  messages.add(Message1.fromSnapshot(element));
                });
                if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                  // Update the message seen status if needed
                  // Implement your logic here
                }
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0.0);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final messageData = snapshot.data!.docs[index];
                    bool isSelected =
                        selectedMessageIds.contains(messageData.id);

                    var date =
                        DateTime.fromMillisecondsSinceEpoch(item.epochTimeMs);
                    var formattedDate = DateFormat('dd MMM yyyy').format(date);

                    // Check the message type
                    if (item.type == 'call') {
                      return ListTile(
                        title: CallMessageBubble(
                          callType: item.callType,
                          callStatus: item.callStatus,
                          callDuration: item.callDuration,
                          isSenderMyUser: item.senderId == widget.myUserId,
                          epochTimeMs: item.epochTimeMs,
                        ),
                      );
                    } else {
                      return ListTile(
                          title: GestureDetector(
                        onLongPress: () {
                          enterSelectionMode(); // Enter selection mode
                          toggleMessageSelection(
                              messageData.id); // Select the message
                        },
                        onTap: isSelectionMode
                            ? () => toggleMessageSelection(
                                messageData.id) // Toggle selection on tap
                            : null, // Only select if in selection mode
                        child: Container(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.transparent,
                          child: ListTile(
                            title: MessageBubble(
                              messageId: messageData.id,
                              chatId: widget.chatId,
                              epochTimeMs: item.epochTimeMs,
                              text: item.text,
                              isSenderMyUser: item.senderId == widget.myUserId,
                              includeTime: true,
                              isSeen: item.seen,
                              type: item.type,
                              lastSeen: messages.first.seen,
                            ),
                          ),
                        ),
                      ));
                    }
                  },
                );
              },
            ),
          ),
          getBottomContainer(context, widget.myUserId)
        ],
      ),
    );
  }

  void enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
  }

  void exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedMessageIds.clear(); // Clear the selection
    });
  }

  void sendMessage(String myUserId, String msg, String type) {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      print("type of Message is $type");
      print("Message is $msg");
      print("User ID of the sender of the Message is $myUserId");
      print(
          "Date and time of the Message in milliseconds since epoch is $currentTimestamp");
      print(
          "Human-readable date and time: ${DateTime.fromMillisecondsSinceEpoch(currentTimestamp).toString()}");
    }

    Message1 message = Message1(
      epochTimeMs: currentTimestamp,
      seen: false,
      senderId: myUserId,
      text: msg,
      type: type,
    );

    _databaseSource.addMessage(widget.chatId, message);
    messageTextController.clear();
  }

  Widget getBottomContainer(BuildContext context, String myUserId) {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: ColoredBox(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    (String code, String message, List<String> invitees) {
                      _startCall('video'); // Track the start of the call
                    };
                       VideoCallFcm.sendCallNotification(
                                                widget.otherUserDeviceToken ?? "",
                                                "smart_call_app",
                                                "007eJxTYLhwLq7i2b4u2QWOVy8FxG5Qe8vgtvHrA4bjt0806j6yuKukwGBokWySmmxkkWJilGKSkpSSaGloamloZGJhbpFqlpyUFKb1K60hkJHh/zZ+FkYGCATx+RiKcxOLSuKTE3Ny4hMLChgYAIFIJgw=",
                                                widget.otherUserName);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoCallScreen1(
                                                  recieverName: widget.otherUserName,
                                                  agoraAppId:
                                                      "18c4ec28d42d4dbda9159124878e6cbb",
                                                  agoraAppToken:
                                                      "007eJxTYLhwLq7i2b4u2QWOVy8FxG5Qe8vgtvHrA4bjt0806j6yuKukwGBokWySmmxkkWJilGKSkpSSaGloamloZGJhbpFqlpyUFKb1K60hkJHh/zZ+FkYGCATx+RiKcxOLSuKTE3Ny4hMLChgYAIFIJgw=", // Use dynamic channel name
                                                  agoraAppCertificate:
                                                      "064b1a009cc248afa93a01234876a4c9", // Use your dynamic token
                                                  agoraAppChannelName:
                                                      "smart_call_app",
                                                ),
                                              ),
                                            );
                  },
                  child: Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: messageTextController,
                  style: const TextStyle(color: Colors.black),
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: const Color(0xff607d8b),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Color(0xff607d8b),
                      ),
                      onPressed: () => _showMultiIcon(),
                    ),
                    contentPadding: const EdgeInsets.only(left: 20),
                    hintText: "Type Something...",
                    hintStyle: const TextStyle(color: Color(0xff607d8b)),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      borderSide: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      borderSide: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 80,
                  // padding: const EdgeInsets.all(15.0),
                  // decoration: BoxDecoration(
                  //     color: Theme.of(context).primaryColor,
                  //     shape: BoxShape.circle),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onTap: () {
                          if (messageTextController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Message cannot be empty',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          if (messageTextController.text.isNotEmpty) {
                            String messageText = messageTextController
                                .text; // Store message text before clearing

                            // Debugging: Print the message to ensure it's not empty
                            print("Sending message: $messageText");

                            // Create and send message
                            Message1 message = Message1(
                              epochTimeMs:
                                  DateTime.now().millisecondsSinceEpoch,
                              seen: false,
                              senderId: widget.myUserId,
                              text: messageText,
                              type: "text",
                            );

                            // Clear the text controller
                            messageTextController.clear();

                            // Add the message to Firestore
                            FirebaseFirestore.instance
                                .collection('chats')
                                .doc(widget.chatId)
                                .collection('messages')
                                .add(message.toMap());

                            FirebaseFirestore.instance
                                .collection('chats')
                                .doc(widget.chatId)
                                .update({'last_message': message.toMap()});

                            // Send FCM notification, passing the message text
                            sendFCMMessage(messageText);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ThreeDotMenu extends StatelessWidget {
  final String chatId; // Add this to get the chatId
  final Function onChatClear; // Callback to remove chat from UI

  const ThreeDotMenu({
    super.key,
    required this.chatId,
    required this.onChatClear,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      surfaceTintColor: Theme.of(context).colorScheme.background,
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'Clear',
          child: ListTile(
            title: Text('Clear'),
          ),
        ),
        const PopupMenuItem(
          value: 'Video Call',
          child: ListTile(
            title: Text('Video Call'),
          ),
        ),
        const PopupMenuItem(
          value: 'Exit',
          child: ListTile(
            title: Text('Exit'),
          ),
        ),
      ],
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onSelected: (value) async {
        if (value == "Clear") {
          _showConfirmationDialog(context);
        } else if (value == "Exit") {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MainPage(tab: 2)));
        } else if (value == "Video Call") {
          print("video call");
        } else {
          print("Error");
        }
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                onChatClear(); // Proceed to delete the chat
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class CallMessageBubble extends StatelessWidget {
  final String? callType;
  final String? callStatus;
  final int? callDuration;
  final bool isSenderMyUser;
  final int epochTimeMs;

  CallMessageBubble({
    required this.callType,
    required this.callStatus,
    this.callDuration,
    required this.isSenderMyUser,
    required this.epochTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    String callInfo = '';
    IconData callIcon = Icons.phone;

    if (callStatus == 'Missed') {
      callInfo = isSenderMyUser
          ? 'You missed a $callType call'
          : 'Missed $callType call';
      callIcon = Icons.phone_missed;
    } else if (callStatus == 'Declined') {
      callInfo = isSenderMyUser
          ? 'You declined a $callType call'
          : 'Declined $callType call';
      callIcon = Icons.call_end;
    } else if (callStatus == 'Not Answered') {
      callInfo = 'Call not answered';
      callIcon = Icons.phone_in_talk;
    } else if (callStatus == 'Ended') {
      String duration = callDuration != null
          ? 'Duration: ${callDuration! ~/ 60}m ${callDuration! % 60}s'
          : '';
      callInfo = isSenderMyUser
          ? 'You ended a $callType call. $duration'
          : '$callType call ended. $duration';
      callIcon = Icons.call;
    } else if (callStatus == 'Started') {
      callInfo = isSenderMyUser
          ? 'You started a $callType call'
          : '$callType call started';
      callIcon = Icons.call_made;
    } else {
      callInfo = 'Unknown call status';
    }

    return Align(
      alignment: isSenderMyUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSenderMyUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              callIcon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                callInfo,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
