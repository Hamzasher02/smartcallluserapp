import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallWithTime extends StatefulWidget {

  final String id;
  final String name;
  final double height, width;
  final bool video;
  const CallWithTime({super.key, required this.id, required this.name, required this.height, required this.width, required this.video});

  @override
  State<CallWithTime> createState() => _CallWithTimeState();
}

class _CallWithTimeState extends State<CallWithTime> {

  late Timer _timer;
  late SharedPreferences _prefs;
  late DateTime _lastCallDate;


  getData() {
    SharedPreferences.getInstance().then((prefs) {
      // prefs.remove('lastCallDate');
      _prefs = prefs;
      _lastCallDate =
          DateTime.parse(_prefs.getString('lastCallDate') ?? '1970-01-01');
    });
      // Start a timer that runs a function every 1 minute
      // _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      //   // Place your Zego Cloud Call check logic here
      //   // This code will be executed every 1 minute
      //   Navigator.pop(context);
      //   //checkZegoCloudCall();
      // });
    // });
  }

  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    getData();
    return ZegoSendCallInvitationButton(
        isVideoCall: widget.video,
        iconSize: Size(widget.width, widget.height),
        buttonSize: Size(widget.width, widget.height),
        resourceID: "hafeez_khan",
        onWillPressed: (){
          return _onWillPressed();
        },
        //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
        invitees: [
          ZegoUIKitUser(
            id: widget.id,
            name: widget.name,
          )
        ]);
    //     :GestureDetector(onTap:(){
    //       setState(() {
    //         setCheck = true;
    //       });
    // },child: Container(color: Colors.red,height: 20,width: 20,));
  }


  Future<bool> _onWillPressed() async {
    // This is a placeholder for the action you want to perform.
    // You can replace this with your logic.
    if (_lastCallDate.year == currentDate.year &&
        _lastCallDate.month == currentDate.month &&
        _lastCallDate.day == currentDate.day) {
      // User has already made a call today
      // if(setCheck){
      //   Navigator.pop(context);
      //   showConfirmDialog(context);
      // }
      print('You can only make a 1-minute call per day.');
      showConfirmDialog(context);
      return false;

    } else {
      // User hasn't made a call today, allow the call
      print('You can make a 1-minute call now.');
      //getData();
      // Update the last call date to today
      _prefs.setString('lastCallDate', currentDate.toIso8601String());
      _lastCallDate = currentDate;
      _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
        // Place your Zego Cloud Call check logic here
        // This code will be executed every 1 minute
        Navigator.pop(context);
        //checkZegoCloudCall();
      });
      return true;

      // Add your Zego Cloud Call logic here
      // Perform the call or any related actions
    }
    // return await showDialog<bool>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     if (_lastCallDate.year == currentDate.year &&
    //         _lastCallDate.month == currentDate.month &&
    //         _lastCallDate.day == currentDate.day) {
    //       // User has already made a call today
    //       // if(setCheck){
    //       //   Navigator.pop(context);
    //       //   showConfirmDialog(context);
    //       // }
    //       print('You can only make a 1-minute call per day.');
    //     } else {
    //       // User hasn't made a call today, allow the call
    //       print('You can make a 1-minute call now.');
    //       temp = true;
    //       getData();
    //       // Update the last call date to today
    //       _prefs.setString('lastCallDate', currentDate.toIso8601String());
    //       _lastCallDate = currentDate;
    //       print(temp);
    //
    //       // Add your Zego Cloud Call logic here
    //       // Perform the call or any related actions
    //     }
    //     return AlertDialog(
    //       title: Text('Confirmation'),
    //       content: Text('Do you really want to perform this action?'),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop(true); // User confirmed.
    //           },
    //           child: Text('Yes'),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop(false); // User canceled.
    //           },
    //           child: Text('No'),
    //         ),
    //       ],
    //     );
    //   },
    // ) ?? false; // If the dialog is dismissed, consider it as "No".
  }

  showConfirmDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      title: "You can only make\n a 1-minute call per day",
      type: QuickAlertType.confirm,
      text: "Enjoy Unlimited calls on Smart Call App\n Pay Now",
      confirmBtnText: 'Pay',
      cancelBtnText: 'Cancel',
      onConfirmBtnTap: (){Navigator.pop(context);},
      confirmBtnColor: Colors.green,
    );
  }

}