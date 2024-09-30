import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/authentication/authentication_screen.dart';
import 'package:smart_call_app/Screens/bottomBar/Tabs/status_tab.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_call_app/Screens/call/agora/ringing_screen.dart';
import 'package:smart_call_app/Screens/chat/chat_screen.dart';
import 'package:smart_call_app/Util/Theme/themes.dart';
import 'package:smart_call_app/Util/my_task_handler.dart';
import 'package:smart_call_app/db/entity/app_user.dart';
import 'Util/k_images.dart';
import 'Widgets/custom_image.dart';
import 'db/provider/user_provider.dart';
import 'firebase_options.dart';

// 1. Global Background Handler - Place this OUTSIDE of any classes
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

void startForegroundService() {
  if (Platform.isAndroid) {
    FlutterForegroundTask.startService(
      notificationTitle: 'Incoming Call',
      notificationText: 'You have an incoming call.',
      callback:
          startCallback, // The callback function to handle the foreground task.
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['type'] == 'call') {
    startForegroundService(); // Start foreground service when receiving call notification

    String channelName = message.data['channelName'];
    String agoraToken = message.data['agoraToken'];
    String receiverName = message.data['receiverName'];

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => RingingScreen(
          channelName: channelName,
          agoraToken: agoraToken,
          recieverName: receiverName,
        ),
      ),
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
var isLoggedIn;
AppUser? myuser;
String token1 = '007';
String myid = '';
FirebaseFirestore db = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn =
      (prefs.getBool('isLogin') == null) ? false : prefs.getBool('isLogin');
  myid = prefs.getString("myid") ?? '';

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  requestPermissions();

  // Fetch user data during initialization
  if (myid.isNotEmpty) {
    await dataFireBase();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(navigatorKey: navigatorKey),
    ),
  );
}

Future<void> getToken() async {
  await FirebaseMessaging.instance.getToken().then((value) {
    token1 = value!;
    saveToken(token1);
  });
}

void saveToken(String token) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(myid).update({
      'token': token,
    });
  } catch (e) {
    print(e.toString());
  }
}

Future<void> dataFireBase() async {
  try {
    final event = await db.collection("users").doc(myid).get();

    if (event.exists) {
      myuser = AppUser(
        id: event.data()?['id'] ?? '',
        name: event.data()?['name'] ?? '',
        gender: event.data()?['gender'] ?? '',
        country: event.data()?['country'] ?? '',
        age: event.data()?['age'] ?? 0,
        profilePhotoPath: event.data()?['profile_photo_path'] ?? '',
        temp1: event.data()?['temp1'] ?? '',
        temp2: event.data()?['temp2'] ?? '',
        temp3: event.data()?['temp3'] ?? '',
        temp4: event.data()?['temp4'] ?? '',
        temp5: event.data()?['temp5'] ?? '',
        token: event.data()?['token'] ?? '',
        status: event.data()?['status'] ?? '',
        likes: event.data()?['likes'] ?? 0,
        type: event.data()?['type'] ?? '',
        views: event.data()?['views'] ?? 0,
      );
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}

void requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MyApp({
    this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) async {
    if (myuser == null && myid.isNotEmpty) {
      await dataFireBase(); // Ensure user data is loaded
    }

    if (myuser != null) {
      String? navigate = message.data['navigate'];

      if (navigate == 'chat_screen') {
        String chatId = message.data['chat_id'] ?? '';
        String otherUserId = message.data['otheruser_id'] ?? '';
        String myUserId = message.data['myuser_id'] ?? '';
        String otherUserName = message.data['otheruser_name'] ?? '';

        if (chatId.isNotEmpty &&
            otherUserId.isNotEmpty &&
            myUserId.isNotEmpty) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => MessageScreen(
                chatId: chatId,
                myUserId: myUserId,
                otherUserId: otherUserId,
                otherUserName: otherUserName,
                user: myuser!,
              ),
            ),
          );
        }
      } else if (navigate == 'status_screen') {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => StatusScreen(myuser: myuser!),
          ),
        );
      } else if (message.data['type'] == 'call') {
        startForegroundService();

        String channelName = message.data['channelName'];
        String agoraToken = message.data['agoraToken'];
        String receiverName = message.data['receiverName'];

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RingingScreen(
              channelName: channelName,
              agoraToken: agoraToken,
              recieverName: receiverName,
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage(tab: 0)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: GetMaterialApp(
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        navigatorKey: widget.navigatorKey,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeModes.darkTheme,
        theme: ThemeModes.lightTheme,
        themeMode: ThemeMode.system,
        supportedLocales: const [
          Locale('en'),
          Locale('el'),
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ],
        localizationsDelegates: const [
          CountryLocalizations.delegate,
        ],
        home: AnimatedSplashScreen(
          backgroundColor: const Color(0xff607d8b),
          splash: const CustomImage(path: Kimages.mainLogo),
          splashIconSize: 200,
          duration: 2500,
          nextScreen: isLoggedIn == null || isLoggedIn == false
              ? const AuthenticationScreen()
              : const MainPage(tab: 0),
        ),
      ),
    );
  }
}
