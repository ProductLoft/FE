import 'package:flutter/material.dart';
import 'package:lang_fe/db/recording_models.dart';
import 'package:lang_fe/pages/audio_player.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
import 'package:provider/provider.dart';

// import 'audio_player.dart';
// import 'audio_recorder.dart';

class AudioPageWidget extends StatefulWidget {
  const AudioPageWidget({super.key, required this.audioID});

  final int audioID;

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

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppBasicInfoProvider>(context, listen: false);
    provider.addPageTrack('audio-page');
  }

  Future<List<Widget>> getAudioPageLayout() async {
    audioRecord = await AudioRecordingProvider().getRecording(widget.audioID);
    // AudioRecord? previousrecording = await AudioRecordingProvider().getRecording(id);
    List<Widget> audioPageLayout = [
      CustomAudioPlayer(
        source: audioRecord?.path ?? 'Audio Not Found',
        onDelete: () {
          AudioRecordingProvider().deleteRecording(widget.audioID);
          setState(() {
            refreshRecordings = true;
          });
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

    return audioPageLayout;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder<List<Widget>>(
          future: getAudioPageLayout(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error12!: ${snapshot.error}');
            } else {
              return Column(
                children: snapshot.data!,
              );
            }
          }),
    ]);
  }
}
