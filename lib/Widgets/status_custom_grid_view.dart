import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../db/remote/firebase_database_source.dart';
import 'country_to_flag.dart';

class StatusCustomGridView extends StatefulWidget {
  final String img;
  final String type;
  const StatusCustomGridView({
    Key? key, required this.img, required this.type,
  }) : super(key: key);
  @override
  State<StatusCustomGridView> createState() => _StatusCustomGridViewState();
}

class _StatusCustomGridViewState extends State<StatusCustomGridView> {

  late VideoPlayerController _controller;
  String type = 'img';
  // VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;


  @override
  void initState() {
//GET SNAP DATA AND CHECK TYPE OF IMAGE OF NOT IMAGE THEN INITIALIZE
//USING URL

    super.initState();

    if (widget.type == 'vid') {
      //VideoPlayerController _controller = VideoPlayerController.network(widget.img);
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.img));
          // ..initialize().then((_) {
        //   // Ensure the first frame is shown after the video is initialized,
        //   //even before the play button has been pressed.
        //   setState(() {});
        // });
      _initializeVideoPlayerFuture = _controller.initialize();
    }
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return type == widget.type
      ?
      Center(
        child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    image: DecorationImage(
                        image: NetworkImage(widget.img),
                        fit: BoxFit.fill),
                  ),
        ))
    :FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff607d8b),),
          );
        }
      },
    )
    ;





    // return Center(
    //     child: Container(
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(12),
    //           image: DecorationImage(
    //               image: NetworkImage(widget.img),
    //               fit: BoxFit.cover),
    //         ),
    //         //color: Colors.orange,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.end,
    //           children: [
    //
    //             Padding(
    //               padding: const EdgeInsets.only(bottom: 10),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Text(
    //                     widget.name,
    //                     style: (const TextStyle(
    //                       /*color: Theme.of(context).colorScheme.primaryVariant*/
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 24)),),
    //                   const SizedBox(width: 10,),
    //                   Text(countryCodeToEmoji(widget.country)),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         )
    //     ));

    // showStatus(BuildContext context, String image,likes,name,country){
    //   return  showMaterialModalBottomSheet(
    //       context: context,
    //       builder: (context) =>

    }
}
