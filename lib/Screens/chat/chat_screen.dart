import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Screens/chat/widget/chat_top_bar.dart';
import 'package:smart_call_app/Screens/chat/widget/message_bubble.dart';
import 'package:smart_call_app/Util/video_call_utils.dart';
import 'package:smart_call_app/Widgets/country_to_flag.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
import 'package:smart_call_app/db/entity/sentmessage.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../../db/entity/app_user.dart';
import '../../db/entity/chat.dart';
import '../../db/entity/message.dart';
import '../../db/remote/firebase_database_source.dart';

class MessageScreen extends StatefulWidget {
  final AppUser user;

  MessageScreen(
      {required this.chatId,
      required this.myUserId,
      required this.otherUserId,
      this.age,
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
  
  String? date;
  String? userType;
  final String myUserId;
  final String otherUserId;
  final String otherUserName;

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
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

  late ZegoUIKitPrebuiltCallInvitationService _callInvitationService;

  @override
  void initState() {
    //dataFireBase();
    super.initState();
    if (kDebugMode) {
      print('The age of the user is ${widget.age}');
      print('The country of the user is ${widget.country}');
      print('The gender of the user is ${widget.gender}');
      print('The image of the user is ${widget.image}');
      print('The name of the user is ${widget.otherUserName}');
    }

    initZego();
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
}){
    

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
                                      Message message = Message(
                                        DateTime.now().millisecondsSinceEpoch,
                                        false,
                                        myid,
                                        "Say Hello 👋",
                                        "text",
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
                                  type == "live"
                                      ? SizedBox(
                                          width: 90.0, // Set your desired width
                                          height:
                                              90.0, // Set your desired height
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: ZegoSendCallInvitationButton(
                                              isVideoCall: true,
                                              resourceID: "zegouikit_call",
                                              invitees: [
                                                ZegoUIKitUser(
                                                  id: id,
                                                  name: name,
                                                ),
                                              ],
                                              icon: ButtonIcon(
                                                  icon: const Icon(
                                                    Icons.videocam_rounded,
                                                    size: 50,
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor:
                                                      Colors.green),
                                            ),
                                          ),
                                        )
                                      : type == "fake"
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DummyWaitingCallScreen(
                                                              userImage: img,
                                                              userName: name,
                                                            )));
                                              },
                                              child: const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  radius: 30,
                                                  child: Icon(
                                                    Icons.videocam_rounded,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
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

  void initZego() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');
    String? storedUserName = prefs.getString('userName');

    if (kDebugMode) {
      print(
          "Id of the current tapped is ${storedUserId ?? "default current user"}");
      print("Name of the current user is $storedUserName");
    }

    // Ensure userID and userName are not null before passing them to Zego
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Utils.appId,
      appSign: Utils.appSignin,
      userID: storedUserId ?? "defaultUserId",
      userName: storedUserName ?? "defaultUserName",
      notifyWhenAppRunningInBackgroundOrQuit: true,
      androidNotificationConfig: ZegoAndroidNotificationConfig(
        channelID: "ZegoUIKit",
        channelName: "Call Notifications",
        sound: "notification",
        icon: "notification_icon",
      ),
      iOSNotificationConfig: ZegoIOSNotificationConfig(
        isSandboxEnvironment: false,
        systemCallingIconName: 'CallKitIcon',
      ),
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        config.topMenuBarConfig.isVisible = true;

        config.topMenuBarConfig.buttons
            .insert(0, ZegoMenuBarButtonName.minimizingButton);

        return config;
      },
    );
  }

  void _uninitializeCallInvitationService() {
    _callInvitationService.uninit();
  }

  @override
  void dispose() {
    super.dispose();
    _uninitializeCallInvitationService();
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
      Message lastMessage, String messageId, String myUserId) {
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
                onTap: (){
                  showUserView(context: context, type: widget.userType!, id: widget.otherUserId, img: widget.image!, name: widget.otherUserName, country: widget.country!, date: widget.date!, age: widget.age!, gender: widget.gender!, myid: widget.myUserId, otherId: widget.otherUserId);
                },
                child: ChatTopBar(user: AppUser.fromSnapshot(snapshot.data!)));
            }),
        actions: const [
          // CallWithTime(id: widget.otherUserId, name: widget.otherUserName, height: 40, width:50, video: false,),
          ThreeDotMenu(),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MainPage(tab: 2)));
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
                        title: MessageBubble(
                          epochTimeMs: item.epochTimeMs,
                          text: item.text,
                          isSenderMyUser: item.senderId == widget.myUserId,
                          includeTime: true,
                          isSeen: item.seen,
                          type: item.type,
                          lastSeen: messages.first.seen,
                        ),
                      );
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
          'Authorization':
              'key=AAAArPo8OQ0:APA91bF4wENvEbhr0n9bdTmoak8aUJN_k4Hb_2y3upvwvHQKI1pStlrTHJpIz9zZfE2J0fbDqxUNIHU3Tgt_bBV8-a9f74DzP7SxpODDTQ0jjn-7I_HUIILM6XxsmS8VbHuSfeM88dLg'
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
    Message1 message = Message1(
      epochTimeMs: DateTime.now().millisecondsSinceEpoch,
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
                child: SizedBox(
                  height: 80, // Set your desired height
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: ZegoSendCallInvitationButton(
                      isVideoCall: true,
                      resourceID: "zegouikit_call",
                      invitees: [
                        ZegoUIKitUser(
                          id: widget.user.id,
                          name: widget.user.name,
                        ),
                      ],
                      icon: ButtonIcon(
                        icon: const Icon(
                          size: 60,
                          Icons.videocam_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onPressed:
                          (String code, String message, List<String> invitees) {
                        _startCall('video'); // Track the start of the call
                      },
                    ),
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
                          } else {
                            sendMessage(
                                myUserId, messageTextController.text, 'text');
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
  const ThreeDotMenu({super.key});

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
      onSelected: (value) {
        // Handle menu item selection here
        if (value == "Exit") {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MainPage(tab: 2)));
        } else if (value == "Video Call") {
          print("video call");
        } else if (value == "Clear") {
          print("Clear");
        } else {
          print("Error");
        }
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
