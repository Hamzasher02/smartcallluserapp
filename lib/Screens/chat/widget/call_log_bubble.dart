import 'package:flutter/material.dart';

class CallLogBubble extends StatelessWidget {
  final String callType;
  final String callStatus;
  final int callDuration;
  final bool isCaller;

  CallLogBubble({required this.callType, required this.callStatus, required this.callDuration, required this.isCaller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: isCaller ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            color: isCaller ? Colors.green : Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$callType call - $callStatus',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Duration: $callDuration sec',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
