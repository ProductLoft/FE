import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:file_picker/file_picker.dart';
import 'platform/audio_recorder_platform.dart';

class Recorder extends StatefulWidget {
  final Future<void> Function(String path) onStop;

  const Recorder({super.key, required this.onStop});

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
            bitRate: 320000,
            sampleRate: 44100,
            numChannels: 2,
            autoGain: true,
            echoCancel: false,
            noiseSuppress: false
        );

        // Record to file
        await recordFile(_audioRecorder, config);

        // Record to stream
        // await recordStream(_audioRecorder, config);

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
      widget.onStop(path);

      downloadWebData(path);
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
      decoration: BoxDecoration(
        color:Theme.of(context).primaryColor.withOpacity(0.1),
        // border: Border.all(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8.0),
          bottom: Radius.circular(8.0),
        ),
      ),
      padding:  EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Container(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                _buildRecordStopControl(),
                _buildPauseResumeControl(),
                SizedBox(width: 8),
                _buildText(),
              ]
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                SizedBox(width: 4),
                Text("OR",style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
              ]
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                _buildRecordUploadControl(),
                SizedBox(width: 8),
                Text("upload own wav")
              ]
            ),
          )
        ]
      )
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // void uploadWav() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['wav'],    //筛选文件类型
  //   );

  //     debugPrint('result===$result');
  //   // final result = await FilePicker.platform.pickFiles(
  //   //   type: FileType.custom,
  //   //   allowedExtensions: ['wav'],
  //   // );
  //   // // FilePickerResult result = await FilePicker.platform.pickFiles();
  //   // debugPrint('result===$result');

  //   // if (result != null) {
  //   //   String fileName = result.files.single.name;
  //   //   String filePath = result.files.single.path;
  //   //   FormData formData = FormData.fromMap({
  //   //     "file": await MultipartFile.fromFile(filePath, filename: fileName),
  //   //   });

  //   //   try {
  //   //     Response response = await Dio().post("YOUR_UPLOAD_URL", data: formData);
  //   //     print(response.data);
  //   //   } catch (e) {
  //   //     print(e);
  //   //   }
  //   // }
  // }

  Widget _buildRecordStopControl() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), // 设置背景色
        borderRadius: BorderRadius.circular(20.0), // 设置圆角
      ),
      child: IconButton(
        selectedIcon: const Icon(Icons.pause),
        icon: (_recordState != RecordState.stop)? const Icon(Icons.stop): const Icon(Icons.mic),
        onPressed: () {
          setState(() {
            (_recordState != RecordState.stop) ? _stop() : _start();
          });
        },
      )
    );
  }

  Widget _buildRecordUploadControl() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), // 设置背景色
        borderRadius: BorderRadius.circular(20.0), // 设置圆角
      ),
      child: IconButton(
        // selectedIcon: const Icon(Icons.pause),
        icon: Icon(Icons.file_upload),
        onPressed: () {
          // uploadWav();
          // setState(() {
          //   (_recordState != RecordState.stop) ? _stop() : _start();
          // });
        },
      )
    );
  }


  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    return IconButton(
      // isSelected: playProgressIndicator,
      selectedIcon: const Icon(Icons.pause),
      icon: (_recordState == RecordState.record)? const Icon(Icons.pause): const Icon(Icons.play_arrow),
      onPressed: () {
        setState(() {
          (_recordState == RecordState.pause) ? _resume() : _pause();
        });
      },
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Waiting to record");
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
