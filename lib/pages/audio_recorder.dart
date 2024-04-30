import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import 'platform/audio_recorder_platform.dart';

class Recorder extends StatefulWidget {
  final Future<void> Function(String path) onStop;
  final String waitToText;

  const Recorder({super.key, required this.onStop, required this.waitToText});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> with AudioRecorderMixin {
  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  bool _textBoxIsVisible = false;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      setState(() => _amplitude = amp);
    });

    super.initState();

    final provider = Provider.of<AppBasicInfoProvider>(context, listen: false);
    provider.addPageTrack('audio-recorder-page');
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.hasPermission()
            ? debugPrint("true")
            : debugPrint("False");
        const encoder = AudioEncoder.wav;

        if (!await _isEncoderSupported(encoder)) {
          return;
        }

        final devs = await _audioRecorder.listInputDevices();
        debugPrint(devs.toString());

        const config = RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 256000,
            sampleRate: 16000,
            numChannels: 1,
            autoGain: true,
            echoCancel: false,
            noiseSuppress: true);

        // Record to file
        await recordFile(_audioRecorder, config);

        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    _textBoxIsVisible = true;
    if (path != null) {
      await widget.onStop(path);

      // downloadWebData(path);
    }
  }

  Future<void> _pause() => _audioRecorder.pause();

  Future<void> _resume() => _audioRecorder.resume();

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.red,
        decoration: const BoxDecoration(
            // color:Theme.of(context).primaryColor.withOpacity(0.1),
            // border: Border.all(color: Colors.red, width: 2.0),
            // borderRadius: BorderRadius.vertical(
            //   top: Radius.circular(8.0),
            //   bottom: Radius.circular(8.0),
            // ),
            ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: (_recordState != RecordState.stop)
            ? Container(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRecordStopControl(
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),),
                              SizedBox(width: 8),
                              _buildPauseResumeControl(),
                              SizedBox(width: 8),
                              _buildTimer(),
                            ]),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildText('Recording'),
                          ])
                    ]))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRecordStopControl(
                                Theme.of(context).primaryColor.withOpacity(0.5),
                               ),
                          ]),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _buildText(widget.waitToText),
                    ])
                  ]));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl(Color _color) {
    return Container(
        width: (_recordState != RecordState.stop)
            ? 60.0
            : 60.0,
        height: ( _recordState != RecordState.stop)
            ? 60.0
            : 60.0,
        decoration: BoxDecoration(
          color: (_recordState != RecordState.stop)
              ? Colors.black.withOpacity(0.05)
              : _color, // 设置背景色
          borderRadius: BorderRadius.circular(
              (_recordState != RecordState.stop) ? 40.0 : 60.0), // 设置圆角
        ),
        child: IconButton(
          selectedIcon: const Icon(Icons.pause, size: 80.0),
          icon: (_recordState != RecordState.stop)
              ? (const Icon(Icons.stop, size: 40.0, color: Colors.red))
              : (const Icon(Icons.mic, size: 40.0, color: Colors.white)),
          onPressed: () {
            setState(() {
              (_recordState != RecordState.stop) ? _stop() : _start();
            });
          },
        ));
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    return Container(
        width: 60.0,
        height: 60.0,
        child: IconButton(
          // isSelected: playProgressIndicator,
          selectedIcon: const Icon(Icons.pause, size: 80.0),
          icon: (_recordState == RecordState.record)
              ? const Icon(Icons.pause, size: 40.0)
              : const Icon(Icons.play_arrow,
                  size: 40.0),
          onPressed: () {
            setState(() {
              (_recordState == RecordState.pause) ? _resume() : _pause();
            });
          },
        ));
  }

  Widget _buildText(String text) {
    // debugPrint(text);
    // if (_recordState != RecordState.stop) {
    //   return _buildTimer();
    // }

    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
