import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'call_with_timer.dart';
import 'country_to_flag.dart';

class CustomCardTile extends StatelessWidget {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String country;
  final String profileImage;
  final VoidCallback? onTapImage;

  CustomCardTile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.country,
    required this.profileImage,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.135,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  onTapImage!.call();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                name.trim(),
                textAlign: TextAlign.start,
                maxLines: 2,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        countryCodeToEmoji(country),
                        style: const TextStyle(fontSize: 20),
                      ),
                      CallWithTime(
                        id: id,
                        name: name,
                        height: 75,
                        width: 45,
                        video: true,
                      ),
                      // ZegoSendCallInvitationButton(
                      // buttonSize: const Size(45,75),
                      // isVideoCall: true,
                      // resourceID: "hafeez_khan", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                      // invitees: [
                      //   ZegoUIKitUser(
                      //     id: id,
                      //     name: name,
                      //   )])
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
