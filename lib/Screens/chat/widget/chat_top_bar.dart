import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/app_user.dart';

class ChatTopBar extends StatelessWidget {
  final AppUser user;

  ChatTopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Stack(
                children: [
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: user.profilePhotoPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  user.status == "online" ? const Positioned(
                    right: 2,
                    bottom: 2,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF39FF14),
                      ),
                    ),
                  ) : const Positioned(
                    right: 2,
                    bottom: 2,
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
          ],
        ),
        // Stack(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         border: Border.all(color: const Color(0xff8097a2), width: 1.0),
        //       ),
        //       child: CircleAvatar(
        //         radius: 22,
        //         backgroundImage: NetworkImage(user.profilePhotoPath),
        //       ),
        //     )
        //   ],
        // ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
