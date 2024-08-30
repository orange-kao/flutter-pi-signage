import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;  // flutter pub add http

void main() {
  runApp(const MyApp());
}

Future<ImageRotater> fetchImageRotater() async{
  Uri uri_base = Uri.base;
  // Uri uri_base = Uri.parse("http://127.0.0.1/signage-reload/?signage_id=01");
  String signage_id = "";
  if (uri_base.queryParameters.containsKey("signage_id")){
    signage_id = uri_base.queryParameters["signage_id"]!;
  }
  Uri get_uri = Uri(scheme: uri_base.scheme, host: uri_base.host, path: "/signage-reload/" + signage_id);
  print("Preview reload URI: " + get_uri.toString());
  http.Response response = await http.get(get_uri);
  print("Status code " + response.statusCode.toString() + ", response body: " + response.body.toString());
  if (response.statusCode == 200){
    List<String> image_uri_list = [];
    for(final image_filename in response.body.split("\n")){
      Uri temp_uri = Uri(scheme: uri_base.scheme, host: uri_base.host, path: "signage-all-slides/signage-" + signage_id + "/" + image_filename);
      image_uri_list.add(temp_uri.toString());
    }
    return ImageRotater(image_uri_list);
  } else {
    throw Exception("Failed to load file list");
  }
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
    String signage_id = "";
    if (Uri.base.queryParameters.containsKey("signage_id")){
      signage_id = Uri.base.queryParameters["signage_id"]!;
      print('Signage ID: ' + signage_id);
    }

    return MaterialApp(
      title: 'Signage [' + signage_id + '] Preview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xff1b5e20),  // dark green
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Please resize this window until green border appear at right and bottom for pixel-by-pixel result'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<ImageRotater> futureImageRotater;

  @override
  void initState(){
    super.initState();
    futureImageRotater = fetchImageRotater();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),

      // limit and match the actual hardware screen size
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1920, maxHeight: 1080),
        // limit aspect ratio even if user's screen have a lower resolution
        child: AspectRatio(
          aspectRatio: 16/9,
          // Background color for area not covered by JPEG image
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: FutureBuilder<ImageRotater>(
                    future: futureImageRotater,
                    builder: (context, snapshot){
                      // ImageRotater(get_file_list())
                      if (snapshot.hasData){
                        return snapshot.data!;
                      } else if (snapshot.hasError){
                        return Text("Unable to load image", style: TextStyle(color: Colors.red.shade400));
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
          ),
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
    return new Image.network(
      widget.photos[_pos],
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
