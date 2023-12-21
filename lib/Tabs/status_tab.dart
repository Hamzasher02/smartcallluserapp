import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/constants.dart';
import 'package:smart_call_app/Widgets/custom_image.dart';
import 'package:smart_call_app/Widgets/status_custom_grid_view.dart';
import 'package:smart_call_app/Widgets/status_video_view.dart';
import 'package:smart_call_app/Widgets/ststus_image_view.dart';
import 'package:uuid/uuid.dart';
import '../Util/k_images.dart';
import '../Widgets/status_bar_list_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../db/entity/app_user.dart';
import '../db/entity/story.dart';
import '../db/remote/firebase_database_source.dart';

class StatusScreen extends StatefulWidget {
  final AppUser myuser;
  const StatusScreen({super.key, required this.myuser});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  List sto=[];
  Future _refresh() async{}

  @override
  void initState() {
    // stoData();
    getFakeUser();
    // TODO: implement initState

    super.initState();
  }

  showStatus(BuildContext context, String image,likes,name,country){
    return  showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover),
        ),
        height: getHeight(context)*0.9,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.favorite_border,size: 55,),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(likes,style: TextStyle(fontSize: 30),),
            ),
            SizedBox(height: 5,),
            CircleAvatar(
              backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
              radius: 30,
              child: const Icon(Icons.chat,size: 40,color: Colors.white,),
            ),
            SizedBox(height: 10,),
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 30,
              child: const Icon(Icons.video_call,size: 50,color: Colors.white,),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name + " " + country,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 30,
                ),
              ],
            )
          ],
        ),
      ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getFakeUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: _refresh,
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 20,top: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                        height: 75,
                        width: getWidth(context)*0.2,
                      child:
                      // Stack(
                      //   children: <Widget>[
                      //     const CircleAvatar(
                      //       radius: 40,
                      //       backgroundImage: AssetImage(Kimages.mainLogo),
                      //     ),
                      //     Positioned(
                      //       bottom: 0.0,
                      //       right: 1.0,
                      //       child:
                      //       Container(
                      //         height: 10,
                      //         width: 20,
                      //         decoration: const BoxDecoration(
                      //           color: Colors.green,
                      //           shape: BoxShape.circle,
                      //         ),
                      //       ),
                      //     )
                      //   ],
                      // ),
                      const CustomImage(
                        path: Kimages.mainLogo,
                      ),
                    ),

                     StatusBarListView(fakeUser: result, myuser: widget.myuser,),

                  ],
                ),
              ),
              ),





              Expanded(
                child:  Padding(
                padding: const EdgeInsets.only(top: 20),
                child:  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    children: List.generate(sto.length, (index) {
                      return GestureDetector(
                        onTap: (){
                         sto[index].type == 'img'
                             ? showStatusImage(context, sto[index].imageUrl, sto[index].likes, sto[index].userId,widget.myuser,)
                             :  showStatusVideo(context, sto[index].imageUrl, sto[index].likes, sto[index].userId,widget.myuser,);
                          // showStatus(
                          //   context,
                          // "https://play-lh.googleusercontent.com/C9CAt9tZr8SSi4zKCxhQc9v4I6AOTqRmnLchsu1wVDQL0gsQ3fmbCVgQmOVM1zPru8UH=w240-h480-rw",
                          // "1k",
                          //  "Ali",
                          // "🌍");
                        },
                          child: StatusCustomGridView(img: sto[index].imageUrl, type: sto[index].type));
                    }
                    )
                ),

              ),
              )

            ],
          ),
        )
      ),
    );
        });
  }

int count=0;
  int temp=0;
  Future stoData() async {
    sto=[];
    print("in function");
    try{
      await db.collection("stories").get().then((event) async {
        print(event.docs.length);
        temp = event.docs.length;
        sto=[];
        for (var doc in event.docs) {
          count=count+1;
          print(count);
          print("lun");
          sto.add(Story(userId: doc.data()['userId'],
              imageUrl: doc.data()['imageUrl'],
              timestamp: doc.data()['timestamp'].toDate(),
              likes: doc.data()['likes'],
              type: doc.data()['type']));
          if(count==temp) break;
        }
      });
    }catch(e){print(e.toString());}
    // String temp='';
    // //fvtList=[];
    // await db.collection("users").doc(widget.myuser.id).collection("favourites").get().then((event) async {
    //   for(var doc in event.docs){
    //     temp = doc.data()['id'];
    //     if(temp!='') {
    //
    //
    //     }
    //   }
    //
    // });
    // if(fvtList.isEmpty){
    //   check=true;
    // }else{
    //   check=true;
    // }
    // final ids = fvtList.map((e) => e.id).toSet();
    // fvtList.retainWhere((x) => ids.remove(x.id));
    // print(fvtList.length);
    return sto;
  }

  List result = [];
  bool tempcheck = false;
  getFakeUser() async {
    await db.collection("users").where("type",isEqualTo: "fake").get().then((event) async {
      result = [];
      var count = 0;
      print(event.docs);
      for (var doc in event.docs) {
        result.add(AppUser(
          id: doc.data()['id'],
          name: doc.data()['name'],
          gender: doc.data()['gender'],
          age: doc.data()['age'],
          country: doc.data()['country'],
          profilePhotoPath: doc.data()['profile_photo_path'],
          token: doc.data()['token'],
          temp1: doc.data()['temp1'],
          temp2: doc.data()['temp2'],
          temp3: doc.data()['temp3'],
          temp4: doc.data()['temp4'],
          temp5: doc.data()['temp5'],
          status: doc.data()['status'],
          likes: doc.data()['likes'],
          type: doc.data()['type'],
          views: doc.data()['views'],
        ));
        count++;
        if (count == event.docs.length) break;
      }
    });
    tempcheck = tempcheck;
    result.shuffle();
    await stoData();
    if (tempcheck == true) {
      Future.delayed(new Duration(seconds: 20), () {
        return result;
      });
    }
  }
}

