import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:smart_call_app/Screens/call/agora/video_call_screen_1.dart';
class RingingScreen extends StatelessWidget {
  final String channelName;
  final String agoraToken;
  final String recieverName;

  RingingScreen({
    required this.channelName,
    required this.agoraToken,
    required this.recieverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incoming Call from $recieverName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$recieverName is calling you...'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Stop the foreground service once the call is accepted
                    FlutterForegroundTask.stopService();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen1(
                          recieverName: recieverName,
                          agoraAppCertificate: '064b1a009cc248afa93a01234876a4c9',
                          agoraAppChannelName: channelName,
                          agoraAppId: '18c4ec28d42d4dbda9159124878e6cbb',
                          agoraAppToken: agoraToken,
                        ),
                      ),
                    );
                  },
                  child: Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Stop the foreground service when the call is declined
                    FlutterForegroundTask.stopService();

                    Navigator.pop(context); // Dismiss the ringing UI
                  },
                  child: Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

