import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

import 'constants.dart';

class NowPlaying extends StatefulWidget {
  late SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<NowPlayingState> key;

  NowPlaying(
      {required this.songInfo, required this.changeTrack, required this.key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NowPlayingState();
  }
}

class NowPlayingState extends State<NowPlaying> {
  double currentValue = 0.0;
  double maxValue = 0.0;
  double minValue = 0.0;
  String currentTime = "";
  String endTime = "";

  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(ColorConstants.nowPlaying),
        backgroundColor: ColorConstants.scaffoldColor,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        actions: const [
          Icon(
            Icons.more_vert,
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 50, 10, 0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: widget.songInfo.albumArtwork == null
                  ? const AssetImage("assets/image/placeholder.png")
                      as ImageProvider
                  : FileImage(File(widget.songInfo.albumArtwork)),
              radius: 75,
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child: Text(
                widget.songInfo.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 70),
              alignment: Alignment.center,
              child: Text(
                widget.songInfo.artist,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300),
              ),
            ),
            Slider(
                min: minValue,
                max: maxValue,
                value: currentValue,
                onChanged: (value) {
                  currentValue = value;
                  player.seek(Duration(milliseconds: currentValue.round()));
                }),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    endTime,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 50, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.changeTrack(false);
                    },
                    icon: const Icon(
                      Icons.skip_previous_sharp,
                      size: 60,
                    ),
                    color: Colors.white,
                  ),
                  IconButton(
                      onPressed: () {
                        changeStatus();
                      },
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 60,
                      )),
                  IconButton(
                    onPressed: () {
                      widget.changeTrack(true);
                    },
                    icon: const Icon(
                      Icons.skip_next_sharp,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void changeStatus() {
    if (mounted) {
      setState(() {
        isPlaying = !isPlaying;
      });
    }
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minValue;
    maxValue = player.duration!.inMilliseconds.toDouble();

    if (mounted) {
      setState(() {
        currentTime = getDuration(currentValue);
        endTime = getDuration(maxValue);
      });
    }
    isPlaying = false;
    changeStatus();


    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      if (currentValue >= maxValue) {
        widget.changeTrack(true);
      }
      if (mounted) {
        setState(() {
          currentTime = getDuration(currentValue);
        });
      }
    });
  }
}
