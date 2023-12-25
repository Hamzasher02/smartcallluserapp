import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_call_app/Screens/chat/widget/chat_top_bar.dart';
import 'package:smart_call_app/Screens/chat/widget/message_bubble.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../Widgets/call_with_timer.dart';
import '../../db/entity/app_user.dart';
import '../../db/entity/chat.dart';
import '../../db/entity/message.dart';
import '../../db/remote/firebase_database_source.dart';

class MessageScreen extends StatefulWidget {
  final AppUser user;

  const MessageScreen({required this.chatId, required this.myUserId, required this.otherUserId, required this.user, required this.otherUserName});

  /// Get user object
  final String chatId;
  final String myUserId;
  final String otherUserId;
  final String otherUserName;

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
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

    var ref = FirebaseStorage.instance.ref().child("users/${widget.myUserId}/images/$fileName.jpg");

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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // myid = prefs.getString("myid")!;
    // try {
    //   await db.collection("users").doc(myid).collection("matches").doc(
    //       widget.otherUserId)
    //       .delete();
    // }
    // catch(e){
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.toString())),
    //   );
    // }
    // try {
    //   await db.collection("users").doc(widget.otherUserId).collection("matches").doc(myid).delete();
    // }
    // catch(e){
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.toString())),
    //   );
    // }
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(
    //         builder: (context) => Home_screen()),
    //         (Route<dynamic> route) => false);
  }

  void checkAndUpdateLastMessageSeen(Message lastMessage, String messageId, String myUserId) {
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
      if ((messageBefore.epochTimeMs - currMessage.epochTimeMs).abs() > halfHourInMilli) {
        return true;
      }
    }
    return messageBefore == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: StreamBuilder<DocumentSnapshot>(
            stream: _databaseSource.observeUser(widget.otherUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return ChatTopBar(user: AppUser.fromSnapshot(snapshot.data!));
            }),
        actions: [
          // CallWithTime(id: widget.otherUserId, name: widget.otherUserName, height: 40, width:50, video: false,),
          CallWithTime(
            id: widget.otherUserId,
            name: widget.otherUserName,
            height: 40,
            width: 50,
            video: true,
          ),
          // ZegoSendCallInvitationButton(
          //      iconSize: const Size(50, 40),
          //     // buttonSize: Size(20, 20),
          //   buttonSize: const Size(50, 40),
          //     isVideoCall: false,
          //     resourceID: "hafeez_khan", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
          //     invitees: [
          //       ZegoUIKitUser(
          //         id: widget.otherUserId,
          //         name: widget.otherUserName,
          //       )]),
          // ZegoSendCallInvitationButton(
          //   //iconSize: Size(50, 50),
          //     iconSize: const Size(50, 40),
          //     buttonSize: const Size(50, 40),
          //     isVideoCall: true,
          //     resourceID: "hafeez_khan", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
          //     invitees: [
          //       ZegoUIKitUser(
          //         id: widget.otherUserId,
          //         name: widget.otherUserName,
          //       )])
          //           PopupMenuButton(
          //           itemBuilder: (context){
          //             return [
          //             PopupMenuItem<int>(
          //               value: 0,
          //               child: Row(
          //                 children: [
          //                   Icon(Icons.person),
          //                   SizedBox(width: 5,),
          //                   Text("Profile")
          //                 ],
          //               ),
          //             ),
          //               PopupMenuItem<int>(
          //                 value: 1,
          //                 child: Row(
          //                   children: [
          //                     Icon(Icons.shield),
          //                     SizedBox(width: 5,),
          //                     Text("Block")
          //                   ],
          //                 ),
          //               ),
          //             ];
          //             },
          //               onSelected:(value){
          //             if(value == 0){
          //               // Navigator.of(context).push(
          //               //               MaterialPageRoute(builder: (context) => chat_profile_view(OtherUserID: widget.otherUserId,) ));
          //              // showProfileDialog(context);
          //             }else if(value == 1){
          //             // showReportDialog(context, widget.otherUserId, unmatch);
          //             }
          //           }
          // )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
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
                List<Message> messages = [];
                snapshot.data?.docs.forEach((element) {
                  messages.add(Message.fromSnapshot(element));
                });
                if (snapshot.data != null && snapshot.data!.docs.length > 0) {
                  checkAndUpdateLastMessageSeen(messages.first, snapshot.data!.docs[0].id, widget.myUserId);
                  // print('hoo');
                  //  print(messages.first.seen);
                }
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0.0);
                }

                // List<bool> showTimeList = messages.length as List<bool>;
                //
                // for (int i = messages.length - 1; i >= 0; i--) {
                //   bool shouldShow = i == (messages.length - 1)
                //       ? true
                //       : shouldShowTime(messages[i], messages[i + 1]);
                //   showTimeList[i] = shouldShow;
                // }

                return ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    print(messages[index].type);
                    print('message type');
                    var date = DateTime.fromMillisecondsSinceEpoch(item.epochTimeMs);
                    var formattedDate = DateFormat('dd MMM yyyy').format(date);
                    print(formattedDate);
                    formattedDate == formattedDate
                        ? const Text(
                            'hello',
                            style: TextStyle(color: Colors.black),
                          )
                        : null;
                    return ListTile(
                      //trailing: Center(child:Text('aaa')),
                      //leading: Center(child:Text('aaa')),
                      // subtitle: Center(child:Text(formattedDate)),
                      title: MessageBubble(
                        epochTimeMs: item.epochTimeMs,
                        text: item.text,
                        isSenderMyUser: messages[index].senderId == widget.myUserId,
                        includeTime: true,
                        isSeen: messages[index].seen,
                        type: messages[index].type,
                        lastSeen: messages.first.seen,
                      ),
                    );
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

  void sendPushNotification(String otherUserid, String body) async {
    String token = '';
    await db.collection("users").doc(otherUserid).get().then((event) async {
      token = event.data()!['token'];
    });
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAArPo8OQ0:APA91bF4wENvEbhr0n9bdTmoak8aUJN_k4Hb_2y3upvwvHQKI1pStlrTHJpIz9zZfE2J0fbDqxUNIHU3Tgt_bBV8-a9f74DzP7SxpODDTQ0jjn-7I_HUIILM6XxsmS8VbHuSfeM88dLg'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': widget.user.name,
            },
            "notification": <String, dynamic>{
              "sound": "default",
              "title": widget.user.name,
              "body": body,
              "android_channel_id": "hafeez",
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void sendMessage(String myUserId, String msg, String type) {
    //if (messageTextController.text.isEmpty) return;
    sendPushNotification(widget.otherUserId, msg);

    Message message = Message(DateTime.now().millisecondsSinceEpoch, false, myUserId, msg, type);

    Chat updatedChat = Chat(widget.chatId, message);
    _databaseSource.addMessage(widget.chatId, message);
    //_databaseSource.addMessage(myUserId, message);
    _databaseSource.updateChat(updatedChat);
    messageTextController.clear();
  }

  Widget getBottomContainer(BuildContext context, String myUserId) {
    return Container(
      height: 80,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: ColoredBox(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: messageTextController,
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
                    fillColor: Theme.of(context).primaryColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(35.0),
              //       boxShadow: [
              //         // BoxShadow(
              //         //     offset: Offset(0, 3),
              //         //     blurRadius: 5,
              //         // )
              //       ],
              //     ),
              //     child: Row(
              //       children: [
              //         SizedBox(width: 15,),
              //         Expanded(
              //           child: TextField(
              //             controller: messageTextController,
              //             textCapitalization: TextCapitalization.sentences,
              //             cursorColor: Theme.of(context).primaryColor,
              //             maxLines: null,
              //             decoration: InputDecoration(
              //                 hintText: "Type Something...",
              //                 hintStyle: TextStyle( color: Theme.of(context).primaryColor),
              //                 fillColor: Theme.of(context).secondaryHeaderColor,
              //                 filled: true,
              //                 border: InputBorder.none),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(width: 5,),
              // Container(
              //   width: 30,
              //   height: 80,
              //   // padding: const EdgeInsets.all(15.0),
              //   // decoration: BoxDecoration(
              //   //     color: Theme.of(context).primaryColor,
              //   //     shape: BoxShape.circle),
              //   child: InkWell(
              //     child: Icon(
              //       Icons.image,
              //       color: Colors.black,
              //     ),
              //     onTap: () {},
              //   ),
              // ),
              const SizedBox(width: 5),
              SizedBox(
                width: 50,
                height: 80,
                // padding: const EdgeInsets.all(15.0),
                // decoration: BoxDecoration(
                //     color: Theme.of(context).primaryColor,
                //     shape: BoxShape.circle),
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      sendMessage(myUserId, messageTextController.text, 'text');
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
