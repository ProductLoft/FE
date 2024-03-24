import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lang_fe/const/utils.dart';

import '../db/recording_models.dart';
import 'audio_player.dart';
import 'audio_recorder.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  String popupValue = 'One';
  String languagePopupValue = 'English';
  bool switchValue = false;
  bool isDisclosureButtonPressed = false;
  bool showPlayer = false;
  bool refreshRecordings = false;
  String? audioPath;
  String commentText = '';

  Future<List<Widget>> getAudioplayers() async {
    List<Recording> previousrecordings = await RecordingProvider().getAll();
    List<Widget> audioPlayers = [];

    for (Recording previousrecording in previousrecordings) {
      audioPlayers.add(Text(previousrecording.comment));
      audioPlayers.add(AudioPlayer(
        source: previousrecording.path,
        onDelete: () {
          RecordingProvider().deleteRecording(previousrecording.id!);
          setState(() {
            refreshRecordings = true;
          });
        },
      ));
    }
    return audioPlayers;
  }

  void _showCommentModal(BuildContext context, String path) {
    TextEditingController _controller = TextEditingController(); // Controller for input

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add context'),
          content: TextField(
            controller: _controller,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Don\'t save'),
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
            ),
            TextButton(
              child: const Text('Save audio'),
              onPressed: () {
                setState(() {
                  commentText = _controller.text;
                  RecordingProvider()
                      .createRecording(path, commentText, "", getCurrentTime());
                });
                Navigator.pop(context); // Close the modal after submission
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column( children: [
      Recorder(
        onStop: (path) {
          if (kDebugMode) {
            print('Recorded file path: $path');
          }
          setState(() {
            _showCommentModal(context, path);
            audioPath = path;
            showPlayer = true;
          });
        },
      ),
          const SizedBox(height: 20),
          const Text(
            'Previous Recordings:',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          FutureBuilder<List<Widget>>(
              future: getAudioplayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: snapshot.data!,
                  );
                }
              }),
        ]);

  }
}
