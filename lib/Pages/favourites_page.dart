import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/constants.dart';
import 'package:smart_call_app/Widgets/custom_grid_view.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../Screens/chat/chat_screen.dart';
import '../Widgets/call_with_timer.dart';
import '../Widgets/country_to_flag.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/fvrt.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';

class FavouritesPage extends StatefulWidget {
  final AppUser myuser;

   const FavouritesPage({super.key, required this.myuser});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {


  @override
  void initState() {
    //fvtData();
    super.initState();
  }

  AppUser? _user;
  String myid='';
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  List<AppUser> fvtList = [];
  bool check=false;


  removeF(String myId, String otherId, String added,index) {
    _databaseSource.removeFavourites(myId, AddFavourites(otherId,added));
    setState(() {
      fvtList.removeAt(index);
    });
  }


  showUserView(BuildContext context, String id,img,name,like,country,date,age,gender,view,myid,myuser,otherId,index) {
    int views;
    views = view++;
    bool fvtVisible = false;
    _databaseSource.addView(id, views);
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                  height: 650,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(img,fit: BoxFit.fill,height: 200,width: 300,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name,style: const TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
                            Column(
                              children: [
                                GestureDetector(
                                    onTap:fvtVisible?null
                                :(){
                                      removeF(myid, otherId, "", index);
                                      int likes;
                                      likes = like-1;
                                      _databaseSource.addFav(id, likes);
                                      setState(() {
                                        fvtVisible = !fvtVisible;
                                      });
                                    },
                                    child: Icon(fvtVisible
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                        color: fvtVisible
                                            ? Colors.black
                                            : Colors.redAccent,
                                      size: 30,)),
                                const SizedBox(height: 5,),
                                Text(like.toString(),style: const TextStyle(fontSize: 22),),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding:const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Row(
                          children: [
                            Text(countryCodeToEmoji(country)),
                            const SizedBox(width: 10,),
                            Text(Country.tryParse(country)!.name,style: const TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),

                      Padding(
                        padding:const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Text(date,style: const TextStyle(fontSize: 18),),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            const Text("Age: " ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            Text("$age" ,style: const TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            const Text("Gender: " ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            Text("$gender" ,style: const TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 10, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                String chatId = compareAndCombineIds(myid,id,);
                                Message message =
                                Message(DateTime.now().millisecondsSinceEpoch, false, myid,"Say Hello 👋","text");
                                _databaseSource.addChat(Chat(chatId, message));
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                      chatId: compareAndCombineIds(myid, id),
                                      myUserId: myid,
                                      otherUserId: id,
                                      user: myuser,
                                      otherUserName: name,
                                    )));
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                Colors.lightBlueAccent.withOpacity(0.7),
                                radius: 30,
                                child: const Icon(
                                  Icons.chat,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            CallWithTime(id: id, name: name, height: 80, width:80, video: true,)
                            // ZegoSendCallInvitationButton(
                            //     isVideoCall: true,
                            //     resourceID: "hafeez_khan", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                            //     invitees: [
                            //       ZegoUIKitUser(
                            //         id: id,
                            //         name: name,
                            //       )])
                          ],
                        ),
                      ),

                    ],
                  )
              ));
        });

      },
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),);
  }


int count=0;
  Future fvtData() async {
    print("in function");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String temp='';
    fvtList=[];
    myid =prefs.getString("myid")!;
    await db.collection("users").doc(widget.myuser.id).collection("favourites").get().then((event) async {
      for(var doc in event.docs){
          temp = doc.data()['id'];
        if(temp!='') {
          try{
            await db.collection("users").doc(temp).get().then((event) async {
              fvtList.add(AppUser(
                id: event.data()!['id'],
                name: event.data()!['name'],
                gender: event.data()!['gender'],
                age: event.data()!['age'],
                country: event.data()!['country'],
                profilePhotoPath: event.data()!['profile_photo_path'],
                token: event.data()!['token'],
                temp1: event.data()!['temp1'],
                temp2: event.data()!['temp2'],
                temp3: event.data()!['temp3'],
                temp4: event.data()!['temp4'],
                temp5: event.data()!['temp5'],
                status: event.data()!['status'],
                likes: event.data()!['likes'],
                type: event.data()!['type'],
                views: event.data()!['views'],
              )
              );
            });
          }catch(e){print(e.toString());}

        }
          count+1;
        print(count);
        print('lun');
        if(count==event.docs.length){
          break;
        }
      }

    });
    // if(fvtList.isEmpty){
    //   check=true;
    // }else{
    //   check=true;
    // }
    final ids = fvtList.map((e) => e.id).toSet();
    fvtList.retainWhere((x) => ids.remove(x.id));
    print(fvtList.length);
    return fvtList;
  }


  Future _refresh() async {}




  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fvtData(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: List.generate(fvtList.length, (index) {
                return GestureDetector(
                    onTap: () {
                    showUserView(context,
                    fvtList[index].id,
                    fvtList[index].profilePhotoPath,
                    fvtList[index].name,
                    fvtList[index].likes,
                    fvtList[index].country,
                    "01-11-2022",
                    fvtList[index].age,
                    fvtList[index].gender,
                    fvtList[index].views,
                    myid,
                    widget.myuser,
                        fvtList[index].id,
                        index);
                    },
                    child: CustomGridView(
                      id: fvtList[index].id,
                      name: fvtList[index].name,
                      age: fvtList[index].age,
                      gender: fvtList[index].gender,
                      country: fvtList[index].country,
                      profileImage: fvtList[index].profilePhotoPath,));
              })),
        ));
    });
  }
}
