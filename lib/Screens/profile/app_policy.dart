import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_call_app/Util/constants.dart';

class AppPolicy extends StatefulWidget {
  const AppPolicy({super.key});

  @override
  State<AppPolicy> createState() => _EditProfileState();
}

class _EditProfileState extends State<AppPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'App Policy',
          style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Call App",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: policyList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policyList[index].title!,
                          textAlign: TextAlign.start,
                          style:  TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          policyList[index].answer!,
                          textAlign: TextAlign.start,
                          style:  TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16.4,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Text(
                  "Disclaimer",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  disclaimerText,
                  style:  TextStyle(
                    color:Theme.of(context).colorScheme.secondary,
                    fontSize: 16.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
