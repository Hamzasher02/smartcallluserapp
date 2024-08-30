import 'package:camera/camera.dart';
import 'package:country_picker/country_picker.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/authentication/authentication_screen.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_call_app/Util/Theme/themes.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'Util/k_images.dart';
import 'Widgets/custom_image.dart';
import 'db/provider/user_provider.dart';

// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

var isLoggedIn;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 

  MobileAds.instance.initialize();
  // await ZegoUIKitSignalingPlugin.init(appID: Utils.appId, appSign: Utils.appSignin);

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn =
      (prefs.getBool('isLogin') == null) ? false : prefs.getBool('isLogin');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  requestPermissions();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  //
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
  });

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Set to false in production
      builder: (context) => MyApp(
        navigatorKey: navigatorKey,
      ), // Your app widget
    ),
  );
}

void requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: GetMaterialApp(
        builder: DevicePreview.appBuilder, // Add this line
        locale: DevicePreview.locale(context), // Add this line
        // useInheritedMediaQuery: true, // Add this line
        navigatorKey: widget.navigatorKey,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        //theme: lightTheme,
        // theme: lightTheme,
        // darkTheme: darkTheme,
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
          backgroundColor: const Color(
              0xff8097a2), // Replace this with the actual color value you want
          splash: const CustomImage(
            path: Kimages.mainLogo,
          ),
          //onLoaded: (composition) {}
          splashIconSize: 200,
          duration: 2500,
          nextScreen: isLoggedIn == null || isLoggedIn == false
              ? const AuthenticationScreen()
              : const MainPage(
                  tab: 0,
                ),
        ),
      ),
    );
  }
}
