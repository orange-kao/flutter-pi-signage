import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
// import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

List<String> get_file_list(){
  final dir = Directory('./signage-slides/');
  List<FileSystemEntity> entries = dir.listSync(recursive: false).toList();
  List<String> result = [];
  for (final entity in entries){
    if (File(entity.path).existsSync()){
      result.add(entity.path);
    }
  }
  result.sort();
  return result;
}

int get_time_from_filename(String filename){
  RegExp exp = RegExp(r'[_]([0-9]+)s[_.]');
  RegExpMatch? match = exp.firstMatch(filename.split("/").last);
  if(match == null){
    return 10;
  }
  int? result_or_null = int.tryParse(match.group(1) ?? "");
  if(result_or_null!=null){
    return result_or_null;
  }
  return 10;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Signage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xff000000),  // black
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Digital Signage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: ImageRotater(get_file_list()),
            ),
          ],
        ),
      ),
    );
  }
}


class ImageRotater extends StatefulWidget {
  List<String> photos;

  ImageRotater(this.photos);

  @override
  State<StatefulWidget> createState() => new ImageRotaterState();
}

class ImageRotaterState extends State<ImageRotater> {
  int _pos = 0;
  Timer? _timer;

  void set_state_custom(){
    _pos = (_pos + 1) % widget.photos.length;
    int time_sec = get_time_from_filename(widget.photos[_pos]);
    Timer? old_timer = _timer;
    _timer = Timer.periodic(new Duration(seconds: time_sec), (xx) {
      setState(set_state_custom);
    });
    old_timer?.cancel();
  }

  @override
  void initState() {
    int time_sec = get_time_from_filename(widget.photos[_pos]);
    _timer = Timer.periodic(new Duration(seconds: time_sec), (xx) {
      setState(set_state_custom);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Display ' + widget.photos[_pos]);
    return new Image.file(
      File(widget.photos[_pos]),
      gaplessPlayback: true,
      fit: BoxFit.contain,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
