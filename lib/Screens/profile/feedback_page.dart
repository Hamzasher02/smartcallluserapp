import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Widgets/custom_textFormField.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _EditProfileState();
}

class _EditProfileState extends State<FeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode subjectFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    initAd();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    subjectFocusNode.dispose();
    messageFocusNode.dispose();
    _interstitialAd!.dispose();
  }

  initAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'FeedBack',
          style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextForm(
                    labelText: "Username",
                    controller: nameController,
                    focusNode: nameFocusNode,
                    maxLines: 1,
                    icon: const Icon(Icons.person),
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  //todo:  email form
                  CustomTextForm(
                    labelText: "Email",
                    controller: emailController,
                    focusNode: emailFocusNode,
                    maxLines: 1,
                    icon: const Icon(Icons.mail_rounded),
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomTextForm(
                    labelText: "Subject",
                    controller: subjectController,
                    focusNode: subjectFocusNode,
                    maxLines: 1,
                    icon: const Icon(Icons.abc),
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomTextForm(
                    labelText: "Write a message..",
                    controller: messageController,
                    focusNode: messageFocusNode,
                    maxLines: 5,
                    icon: const Icon(Icons.message),
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 2,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_isAdLoaded) {
                  _interstitialAd!.show();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const MainPage(tab: 3)),
                    (route) => false,
                  );
                }
              } else {
                print("Error");
              }

              nameController.clear();
              emailController.clear();
              subjectController.clear();
              messageController.clear();
            },
            icon: const Icon(
              Icons.vpn_key_rounded,
              color: Colors.black,
            ),
            label: Text(
              "Submit",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }
}
