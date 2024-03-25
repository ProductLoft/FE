import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lang_fe/pages/audio_player.dart';
import 'package:lang_fe/db/recording_models.dart';
import 'package:record/record.dart';

import '../db/recording_models.dart';

// import 'audio_player.dart';
// import 'audio_recorder.dart';

class AudioPageWidget extends StatefulWidget {
  const AudioPageWidget({super.key, required this.audioID});

  final String audioID;

  @override
  State<AudioPageWidget> createState() => _AudioPageWidgetState();
}

class _AudioPageWidgetState extends State<AudioPageWidget> {
  AudioRecord? audioRecord;
  String popupValue = 'One';
  String languagePopupValue = 'English';
  bool switchValue = false;
  bool isDisclosureButtonPressed = false;
  bool showPlayer = false;
  bool refreshRecordings = false;

  Future<List<Widget>> getAudioplayers() async {
    audioRecord = await AudioRecordingProvider().getRecording(widget.audioID);
    List<AudioRecord> previousrecordings = await AudioRecordingProvider().getAll();
    List<Widget> audioPlayers = [
      CustomAudioPlayer(
        source: audioRecord?.path ?? 'Audio Not Found',
        onDelete: () {
          // RecordingProvider().deleteRecording(1);
          // setState(() {
          //   refreshRecordings = true;
          // });
        },
      ),
      const SizedBox(height: 20),
      const Text(
        'Insights:',
        style: TextStyle(
          fontSize: 15,
        ),
      )
    ];

    for (AudioRecord previousRecording in previousrecordings) {
      debugPrint(previousRecording.comment);
      Widget customPlayer = Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Text(previousRecording.comment),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  debugPrint('Card tapped.');
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            // Example: 16 pixels on all sides
                            child: Column(
                                // mainAxisSize: MainAxisSize.max,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date: ${previousRecording.timestamp}"),
                                  Text(previousRecording.comment),
                                ])),
                      ])
                ])),
          ),
          // Container(
          //     width: double.infinity,
          //     child:
          //
          //
          //     InputChip(
          //       label: const Text('Input'),
          //       onPressed: () {},
          //       onDeleted: () {},
          //     )),
          // Your existing player widget
        ],
      );
      // child: AudioPlayer(
      //   source: previousrecording.path,
      //   onDelete: () {
      //     RecordingProvider().deleteRecording(previousrecording.id!);
      //     setState(() {
      //       refreshRecordings = true;
      //     });
      //   },
      // ),
      // );

      audioPlayers.add(customPlayer);
      // audioPlayers.add(AudioPlayer(
      //   source: previousrecording.path,
      //   onDelete: () {
      //     RecordingProvider().deleteRecording(previousrecording.id!);
      //     setState(() {
      //       refreshRecordings = true;
      //     });
      //   },
      // ));
    }
    return audioPlayers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
