import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor,radius: 20,),
      title: Text("Name ",style: (TextStyle(color: Theme.of(context).colorScheme.primary)),),
      trailing: Icon(Icons.heart_broken),
    );
  }
}
