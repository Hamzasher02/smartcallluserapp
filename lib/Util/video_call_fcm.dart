import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class VideoCallFcm {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "smart-call-app",
      "private_key_id": "a6097eab06502ca4adeed426d6f0e7beb27b2eb8",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCSvvNuMvaJzVbD\nsnGJ7Eu6axS7WO0G4ZKeGXlDufrpx9rLrthbXuHKn/DxHZcRwVBL4YOi3YbAFK2N\njtAjzP/fs/lLuDyYX/3nDzpzWzFMu6970nrnupBfXFNOamold1EiQhTnS5nEXzAB\nxvZpYhaqF8Av+LQxNMtMUL0aG2+ScF2CXWWs3NAGNNgzTR4ZAvZx2uVWPf8op5L0\nINZiUz3ZcMziU9EQ4GjPqPYiP9TBDnrNLkjxaeW8/Z6kh5uFPU4TuHlWB4p0xQ9l\nnb/p/F6qkszh9Q/acrUYGWXz2sRJKwnJVvdCj+K/NKYCVM2XzcfcjHyBkZiyzdHe\n4bAj6NChAgMBAAECggEAFDIid4KdCocPj1xSIuy52VyeXFBXQrCtyINx/H+uiBkg\nxBJ6pUyQH55WfyCW53Mm9WKChtodDvdpkUdb3ul6N5Ph1elzsXbYj0G5xiGBTfGw\nq4ZistyqvO0MbAjaNfDPYjsc/F4bufpttXjn9cXxn5QoN5HvXqxI5GZiOCMZfloy\nMpYK/010LL8nYXq6xR2m/mqFsLdmqmrk9FO1ksIzH7oIa4pnwWLj6jyc0ThPE/Ml\nV8xhFIawAZ7u/BxwoJBetBdQXnYLa707q3xVJ2PT94AAjhSxSpeDoLrp5okY58tz\n5XOKj+UTN2u8UchaSRO2u484GPXGmoKXQ9YyKAddzwKBgQDCtEI297Qvk2dNE7bq\ng7FXiy4OiJl8o/ofQrNoiGwGMZ7ipIjzPwjSRJZu3gGk2TEUa2PAAh/9DcGOQQHr\nCu1L/Rf7ad1qxQbxn5b9RXfqqjUDZJ+SMFFDGyQdY7Y735DLFzGvxJmos7d97Wyc\nBBsNbo3TpzN8dARmzt7x2hkBDwKBgQDA8Zs+c0wmDjRUJE8xyQyIk3ETZOSLjJg9\nQzKYFf8P+nAz2bgY0c9DZ+76Kl5HoGPl/knV+6CwWYxXma3UjWoR/4XQI95YO0Ew\n+4rZwRXZThgMcU6GyBgoZfzxcWsQ8AOVMhViakKaIq3a2eTbUrrHu8eT+OWmu1Nd\noBHJVkyzTwKBgCGnhsp5hmuyzuhDwBpJKR44sH1SnzUsIs/Ed75Z1lI7wXrrdcCV\n5LBzqoz/UslrwVAGP/ewZlcXSZ2NHwfBm8LGvJ54bg1GgSzCqRaeK1wkj4VGn05l\ni6ZNyrBJy/YNbrmsCKqZEPZYGh9qKpvNGd/4fAtZm0ynwRsEJwUm7auBAoGBAKNu\nxFqE3XbKx2aSjwaTz2sMwVZ1OuY+BGK4Pe33i+Mj9tDk1f0oE5F8Q0BijRPM93HF\nERQRnc5jO+6j/UuzMarnL5jcGSXRo2nzWG0VEgXNEa/QdnzSlyv5H+YAdXmWZOKG\n1vhTG/Fl+LANq75f+FjhZa+gwB6YRIhk40wRLs0fAoGBALMEE4mLeu7NFjNMd+di\nkbn08patjnWAJAAGWgU8ZTl6gZCCgwJZd2BODgTkL2mo1y3/0tPlXGiVUUKjtATt\n3/l9YMiC6QXrAms+i4a1cUNSz1ObziYIq4g49yAmHeFAsDG8RssNZzKLYc8GiPfS\nEPBJ/1A+O7iAtlp7Hwz6t90a\n-----END PRIVATE KEY-----\n",
      "client_email": "smart-call-app@appspot.gserviceaccount.com",
      "client_id": "100437911684667732755",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/smart-call-app%40appspot.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/drive.file"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    if (kDebugMode) {
      print("The Server key is ${credentials.accessToken.data}");
    }
    return credentials.accessToken.data;
  }

  static Future<void> sendCallNotification(String currentUserName,String inviteeToken,
      String channelName, String agoraToken, String recieverName) async {
    if (kDebugMode) {
      print("The reciver name is $recieverName");
      print("The agora token is $agoraToken");
      print("The channel Name is $channelName");
      print("The invitee token is $inviteeToken");
            print("Current user name is $currentUserName");

    }
    final String accessToken = await getAccessToken();

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/smart-call-app/messages:send'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "message": {
          "token": inviteeToken, // Device token of the recipient
          "data": {
            // Use 'data' only, not 'notification'
            "type": "call",
            "receiverName": recieverName,
            "callerName":currentUserName,
            "channelName": channelName,
            "agoraToken": agoraToken,
            "action": "incoming_call" , // Pass the action as part of the data payload

            "click_action":
                "FLUTTER_NOTIFICATION_CLICK" // This is important for handling the background state
          }, // Custom data
          "notification": {
            // Optional: Display notification
            "title": "Incoming Call", // Change as needed
            "body": "You have an incoming call." // Change as needed
          },
          "android": {
            "priority": "high" // Set priority for Android devices
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      print('Call notification sent successfully.');
    } else {
      print('Failed to send call notification: ${response.body}');
    }
  }
}
