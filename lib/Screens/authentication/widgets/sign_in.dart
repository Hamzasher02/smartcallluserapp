// import 'package:flutter/material.dart';
// import 'package:smart_call_app/Screens/main_page.dart';
//
// class SignIn extends StatefulWidget {
//   const SignIn({super.key});
//
//   @override
//   State<SignIn> createState() => _SignInState();
// }
//
// class _SignInState extends State<SignIn> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 TextFormField(
//                   onTap: () {
//                     setState(() {});
//                   },
//                   // controller: _userPhoneController,
//                   keyboardType: TextInputType.name,
//                   decoration: const InputDecoration(
//                     hintText: 'User Name',
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 TextFormField(
//                   onTap: () {
//                     setState(() {});
//                   },
//                   // controller: _userPhoneController,
//                   keyboardType: TextInputType.name,
//                   decoration: const InputDecoration(
//                     hintText: 'Password',
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 SizedBox(
//                   width: 400,
//                   height: 50,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Theme.of(context).colorScheme.secondary,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const MainPage()));
//                       },
//                       child: Text(
//                         'Sign In',
//                         style: TextStyle(
//                             fontSize: 18,
//                             color: Theme.of(context).colorScheme.primary),
//                       )),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
