// import 'package:smart_call_app/db/remote/firebase_database_source.dart';

// class CallHandler {
//   final FirebaseDatabaseSource _firebaseService = FirebaseDatabaseSource();

//   Future<void> onCallInitiated({
//     required String myUserId,
//     required String otherUserId,
//     required String callStatus, // 'video' or 'voice'
//   }) async {
//     await _firebaseService.storeCallInfo(
//       myUserId: myUserId,
//       otherUserId: otherUserId,
//       callType: 'received',
//       callStatus: callStatus,
//       isIncoming: false,
//     );
//   }

//   Future<void> onCallReceived({
//     required String myUserId,
//     required String otherUserId,
//     required String callStatus, // 'video' or 'voice'
//   }) async {
//     await _firebaseService.storeCallInfo(
//       myUserId: myUserId,
//       otherUserId: otherUserId,
//       callType: 'missed',
//       callStatus: callStatus,
//       isIncoming: true,
//     );
//   }
// }
