import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget {
  final String _videoID;
  final String _videoTitle;

  const VideoPlayer(this._videoID, this._videoTitle, {Key? key}) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState(_videoID, _videoTitle);
}

class _VideoPlayerState extends State<VideoPlayer> {
  String videoID;
  String videoTitle;

  _VideoPlayerState(this.videoID, this.videoTitle);

  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoID,
      flags: const YoutubePlayerFlags(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          videoTitle,
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
      body: YoutubePlayer(
        controller: _controller,
        actionsPadding: const EdgeInsets.only(left: 16.0),
        bottomActions: [
          CurrentPosition(),
          const SizedBox(width: 10.0),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 10.0),
          RemainingDuration(),
          //FullScreenButton(),
        ],
      ),
    );
  }
}
