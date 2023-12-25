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
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff8097a2), width: 1.0),
              ),
              child: CircleAvatar(radius: 22, backgroundImage: NetworkImage(user.profilePhotoPath)),
            )
          ],
        ),
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
