// import 'package:flutter/material.dart';
//
// const Color primaryColor = Color(0xFFFFffff);
// const Color blackColor = Color(0xff192d60);
// const Color borderColor = Color(0xFFB0D8FF);
// const Color greenColor = Color(0xFF34A853);
// final Color grayColor = const Color(0xff0B2C3D).withOpacity(.3);
// const Color redColor = /*Color(0xff244389)*/ Color(0xff31489b);
// final Color statusColor = /*Color(0xff244389)*/ Color(0xff31489b).withOpacity(.06);
// const Color iconGreyColor = Color(0xff85959E);
// const Color paragraphColor = Color(0xff18587A);
// const greenGredient = [redColor, redColor];
//
//
// const Color darkPrimaryColor = Colors.black12;
// const Color darkblackColor = Color(0xff192d60);
// const Color darkborderColor = Color(0xFFB0D8FF);
// const Color darkgreenColor = Color(0xFF34A853);
// final Color darkgrayColor = const Color(0xff0B2C3D).withOpacity(.3);
// const Color darkredColor = Color(0xff244389);
// final Color darkiconGreyColor = Color(0xff85959E).withOpacity(.3);
// const Color darkparagraphColor = Color(0xff18587A);
// const darkgreenGredient = [redColor, redColor];
//
// // #duration
// const kDuration = Duration(milliseconds: 300);
//
// final _borderRadius = BorderRadius.circular(4);
//
// var inputDecorationTheme = InputDecoration(
//   isDense: true,
//   contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//   hintStyle: const TextStyle(fontSize: 18, height: 1.667),
//   border: OutlineInputBorder(
//     borderRadius: _borderRadius,
//     borderSide: const BorderSide(color: Colors.white),
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: _borderRadius,
//     borderSide: const BorderSide(color: Colors.white),
//   ),
//   enabledBorder: OutlineInputBorder(
//     borderRadius: _borderRadius,
//     borderSide: const BorderSide(color: Colors.white),
//   ),
//   fillColor: primaryColor,
//   filled: true,
//   focusColor: primaryColor,
// );
//
// final gredientColors = [
//   [const Color(0xffF6290C), const Color(0xffC70F16)],
//   [const Color(0xff019BFE), const Color(0xff0077C1)],
//   [const Color(0xff161632), const Color(0xff3D364E)],
//   [const Color(0xffF6290C), const Color(0xffC70F16)],
//   [const Color(0xff019BFE), const Color(0xff0077C1)],
//   [const Color(0xff161632), const Color(0xff3D364E)],
// ];
import 'package:flutter/cupertino.dart';
import 'package:smart_call_app/db/Models/policy_model.dart';

const kDuration = Duration(milliseconds: 300);

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

List<PolicyClass> policyList = [
  PolicyClass(
    title: "User Conduct:",
    answer: '''
  • Users must be respectful and considerate towards others.
  • Harassment, hate speech, or any form of abusive behavior will not be tolerated.
  • Users are responsible for the content they share, including photos and messages.
  ''',
  ),
  PolicyClass(
    title: "Age and Eligibility:",
    answer: '''
  • Users must be at least 18 years old to use the app.
  • Any misrepresentation of age or identity is strictly prohibited.
  ''',
  ),
  PolicyClass(
    title: "Profile and Content Guidelines:",
    answer: '''
  • Users must provide accurate information in their profiles.
  • Prohibited content includes nudity, explicit or offensive material, and copyrighted content without proper authorization.
  • The app reserves the right to review and remove any content that violates these guidelines.
  ''',
  ),
  PolicyClass(
    title: "Safety and Privacy:",
    answer: '''
  • Users are encouraged to exercise caution when sharing personal information.
  • The app employs security measures, but users should also be vigilant regarding their own safety.
  • Report any suspicious or inappropriate behavior to our support team.
  ''',
  ),
  PolicyClass(
    title: "Reporting and Blocking:",
    answer: '''
  • Users can report any violations of the app's policies.
  • The app provides a blocking feature to allow users to control their interactions.
  ''',
  ),
  PolicyClass(
    title: "Moderation and Enforcement:",
    answer: '''
  • The app reserves the right to monitor and moderate user activity to ensure compliance with policies.
  • Violations may result in warnings, suspensions, or permanent account removal, depending on the severity of the offense.
  ''',
  ),
  PolicyClass(
    title: "Consent and Respect:",
    answer: '''
  • Users must obtain explicit consent before sharing personal information or engaging in private conversations.
  • Respect boundaries and communicate openly with others.
  ''',
  ),
  PolicyClass(
    title: "Meeting in Person:",
    answer: '''
  • Users are responsible for their own safety when arranging to meet in person.
  • Choose public locations for initial meetings and inform a friend or family member about the meeting details.
  ''',
  ),
  PolicyClass(
    title: "Terms of Service:",
    answer: '''
  • Users must adhere to the terms of service outlined by the app.
  ''',
  ),
  PolicyClass(
    title: "Continuous Improvement:",
    answer: '''
  • The app is committed to continuous improvement and welcomes user feedback to enhance safety and user experience.
  ''',
  ),
];

String disclaimerText = """
SMART CALL APP is not responsible for the actions of its users and cannot guarantee the authenticity of user-provided information.\n
By using SMART CALL APP, users agree to abide by these policies. The app reserves the right to update and modify these policies as needed.\n
This is a general template, and you may need to consult with legal professionals to ensure that your policy complies with relevant laws and regulations.\n
""";
