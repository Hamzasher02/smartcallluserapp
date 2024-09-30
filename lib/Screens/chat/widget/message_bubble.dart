import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../db/entity/utils.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';

class MessageBubble extends StatefulWidget {
  final int epochTimeMs;
  final String text;
  final bool isSenderMyUser;
  final bool includeTime;
  final bool? isSeen;
  final String type;
  final bool? lastSeen;
  final String messageId;
  final String chatId;

  MessageBubble({required this.epochTimeMs,required this.chatId,required this.messageId, required this.text, required this.isSenderMyUser, required this.includeTime, required this.isSeen, required this.type, required this.lastSeen});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(kDebugMode){
      print("The message Id is ${widget.messageId}");
    }
  }
 // Method to show the confirmation dialog
 

  showimagedialog(BuildContext context, String img) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Cancel')),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton.icon(
                  onPressed: () async {
                    final status = await Permission.storage.request();

                    if (status.isGranted) {
                      final externalDir = await getExternalStorageDirectory();

                      final id = await FlutterDownloader.enqueue(
                        url: widget.text,
                        savedDir: externalDir!.path,
                        fileName: "image",
                        showNotification: true,
                        openFileFromNotification: true,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Image Downloading'),
                      ));
                    } else {}

                    // downloadImage(context, img);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save')),
            ],
            backgroundColor: Colors.transparent,
            content: Image.network(img),
          );
        });
  }

  Future downloadImage(BuildContext context, String img) async {
    //final url = await ref.getDownloadURL();

    final tempDir = await getApplicationDocumentsDirectory();
    final path = '${tempDir.path}/${'image'}';

    await Dio().download(img, path);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Image Downloaded'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: widget.isSenderMyUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
         
          widget.type.compareTo('text') == 0
              ? Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: Material(
                    borderRadius: widget.isSenderMyUser
                        ? const BorderRadius.only(
                            topRight: Radius.circular(0),
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                    elevation: 5.0,
                    color: widget.isSenderMyUser ? Theme.of(context).primaryColorLight : Theme.of(context).colorScheme.secondary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                              right: 60,
                              top: 0,
                              bottom: 0,
                            ),
                            child: Text(
                              widget.text,
                              style:TextStyle(color:Theme.of(context).colorScheme.secondaryContainer),
                            ),
                          ),
                          widget.isSenderMyUser
                              ? Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        convertEpochMsToDateTime(widget.epochTimeMs),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                      ),
                                      Icon(
                                        Icons.done_all,
                                        size: 12,
                                        color: widget.isSeen == true
                                            ? Colors.lightBlueAccent
                                            : widget.lastSeen == true
                                                ? Colors.lightBlueAccent
                                                : Colors.black54,
                                      )
                                    ],
                                  ),
                                )
                              : Positioned(
                                  right: 0,
                                  top: 8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        convertEpochMsToDateTime(widget.epochTimeMs),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                      ),
                                   
                                    ],
                                  ),
                                ),
                        ],
                      ),
                  
                    ),
                  ),
                )
              : widget.type.compareTo('doc') == 0
                  ? Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Material(
                        borderRadius: widget.isSenderMyUser
                            ? const BorderRadius.only(
                                topRight: Radius.circular(0),
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                        elevation: 5.0,
                        color: widget.isSenderMyUser ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 0,
                                  right: 0,
                                  top: 0,
                                  bottom: 15,
                                ),
                                child: GestureDetector(
                             
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (_) => PDFViewerCachedFromUrl(
                                          url: widget.text,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/pdf.svg',
                                        height: 50,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      // Icon(Icons.document_scanner_outlined,size: 50,),
                                      const Text(
                                        'View PDF',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),

                                // Image.network(text),
                              ),
                              widget.isSenderMyUser
                                  ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            convertEpochMsToDateTime(widget.epochTimeMs),
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                          ),
                                          Icon(
                                            Icons.done_all,
                                            size: 12,
                                            color: widget.isSeen == true ? Colors.lightBlueAccent : Colors.black54,
                                          )
                                        ],
                                      ),
                                    )
                                  : Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            convertEpochMsToDateTime(widget.epochTimeMs),
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Material(
                        borderRadius: widget.isSenderMyUser
                            ? const BorderRadius.only(
                                topRight: Radius.circular(0),
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                        elevation: 5.0,
                        color: widget.isSenderMyUser ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showimagedialog(context, widget.text);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                      bottom: 15,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.text!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                    // Image.network(text),
                                    ),
                              ),
                              widget.isSenderMyUser
                                  ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            convertEpochMsToDateTime(widget.epochTimeMs),
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                          ),
                                          Icon(
                                            Icons.done_all,
                                            size: 12,
                                            color: widget.isSeen == true ? Colors.lightBlueAccent : Colors.black54,
                                          )
                                        ],
                                      ),
                                    )
                                  : Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            convertEpochMsToDateTime(widget.epochTimeMs),
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.isSenderMyUser ? Colors.black : Colors.black, fontWeight: FontWeight.normal, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached PDF From Url'),
      ),
      body: const PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              Text('$progress'),
            ],
          ),
        ),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
