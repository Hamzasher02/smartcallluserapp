import 'package:flutter/material.dart';

import 'country_to_flag.dart';

class CustomGridView extends StatelessWidget {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String country;
  final String profileImage;

  CustomGridView({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.country,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(profileImage), fit: BoxFit.cover),
            ),
            //color: Colors.orange,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: (TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
