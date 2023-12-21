import 'package:flutter/material.dart';

class ChatingListView extends StatelessWidget {
  const ChatingListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
                'https://pbs.twimg.com/media/FjU2lkcWYAgNG6d.jpg')),
        title: const Text(
          "Name",
          style: TextStyle(fontSize: 20),
        ),
        subtitle: const Text(
          'Message',
          style: TextStyle(fontSize: 16),
        ),
        trailing: Column(
          children: const [
            Text(
              "Date",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 4,
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.red,
              child: Text(
                '1',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
