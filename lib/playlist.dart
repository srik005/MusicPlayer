import 'dart:io';
import 'package:earningdesigns/constants.dart';
import 'package:earningdesigns/nowplaying.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class PlayList extends StatefulWidget {
  const PlayList({Key? key}) : super(key: key);

  @override
  _SongState createState() => _SongState();
}

class _SongState extends State<PlayList> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songsList = [];
  int currentIndex = 0;
  final GlobalKey<NowPlayingState> key = GlobalKey<NowPlayingState>();

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songsList.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState?.setSong(songsList[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorConstants.scaffoldColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: ColorConstants.home),
          BottomNavigationBarItem(
              icon: Icon(Icons.music_note), label: ColorConstants.songs),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: ColorConstants.setting),
        ],
      ),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(ColorConstants.playlist),
        backgroundColor: ColorConstants.scaffoldColor,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          /*Container(
            padding: const EdgeInsets.fromLTRB(50, 50, 50, 50),
            width: 350,
            height: 350,
            child: const CircleAvatar(
              radius: 25,
            ),
          ),*/
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: songsList[index].albumArtwork == null
                            ? const AssetImage("assets/image/placeholder.png")
                                as ImageProvider
                            : FileImage(File(songsList[index].albumArtwork)),
                      ),
                      title: Text(
                        songsList[index].title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(songsList[index].artist,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        currentIndex = index;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NowPlaying(
                                  changeTrack: changeTrack,
                                  songInfo: songsList[currentIndex],
                                  key: key,
                                )));
                      },
                    ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: songsList.length),
          )
        ],
      ),
    );
  }

  void getSongs() async {
    songsList = await audioQuery.getSongs();
    if (kDebugMode) {
      print("Songs list $songsList");
    }
    setState(() {
      songsList = songsList;
    });
  }
}
