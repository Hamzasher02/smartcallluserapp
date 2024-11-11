import 'package:smart_call_app/db/entity/sentmessage.dart';
import 'package:smart_call_app/db/remote/firebase_database_source.dart';

class ChatBuddyComponent {
  FirebaseDatabaseSource _databaseSource=FirebaseDatabaseSource();
    void chatBuddySent(String myid, String otherid, String sent) async {
    _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
  }

  void chatBuddyReceived(String otherid, String myid, String received) async {
    //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
    _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
  }

}