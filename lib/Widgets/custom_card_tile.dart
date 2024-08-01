import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_call_app/Screens/call/agora/screen_video_call.dart';
import 'country_to_flag.dart';

class CustomCardTile extends StatelessWidget {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String country;
  final String profileImage;
  final String status;
  final VoidCallback? onTapImage;

  CustomCardTile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.country,
    required this.profileImage,
    required this.status,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.135,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
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
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: profileImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      status == "online"
                          ? const Positioned(
                              right: 2,
                              bottom: 10,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Color(0xFF39FF14),
                                ),
                              ),
                            )
                          : const Positioned(
                              right: 2,
                              bottom: 10,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                name.trim(),
                textAlign: TextAlign.start,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VideoCallScreen(
                                remoteUid: int.tryParse(id),
                                username: name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.videocam_rounded,
                          size: 30,
                          color: Colors.green,
                        ),
                      ),
                      // CallWithTime(
                      //   id: id,
                      //   name: name,
                      //   height: 75,
                      //   width: 45,
                      //   video: true,
                      // ),
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
