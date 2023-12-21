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

  CustomCardTile(
      {required this.id,
        required this.name,
        required this.age,
        required this.gender,
        required this.country,
        required this.profileImage,
        });


  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height * .1,
                width: MediaQuery.of(context).size.width * .3,
                child: Center(
                    child: Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ))),
            Column(
              children: [
               Text(countryCodeToEmoji(country),style: const TextStyle(fontSize: 20),)
              ],
            ),
            Column(
              children: [
                CallWithTime(id: id, name: name, height: 75, width: 45, video: true,)
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
    );
  }
}
