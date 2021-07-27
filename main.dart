import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_downloader/flutter_downloader.dart';
Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
   WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Example_app()
    );
  }
}

class Example_app extends StatefulWidget {
  Example_app({Key? key}) : super(key: key);

  @override
  _Example_appState createState() => _Example_appState();
}

class _Example_appState extends State<Example_app> {
  List<String?> list = [];
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  int progress = 0;
  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort?.send([id, status, progress]);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");


    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[0];
      });

      print(progress);
    });


    FlutterDownloader.registerCallback(downloadingCallback);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: 'https://www.twicenest.com/board',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        }
      ),
      floatingActionButton:_buildShowUrlBtn()
      );
  }
  
  void downloadfile(___url) async{
       final status = await Permission.storage.request();

       if (status.isGranted) {
        final externalDir = await getExternalStorageDirectory();

         await FlutterDownloader.enqueue(
         url: ___url,
         savedDir: externalDir!.path,
         fileName: ___url,
         showNotification: true,
         openFileFromNotification: true,
                  );


                } else {
                  print("Permission deined");
  }}
  
  void makeRequest(_url) async{
    list.clear();
    final response = await http.get(Uri.parse(_url));
    //If the http request is successful the statusCode will be 200
    if(response.statusCode == 200){
    
      dom.Document document = parser.parse(response.body);
      final docu = document.getElementsByTagName('article');
      final docu2 = document.getElementsByTagName('article')[0].innerHtml.toString();
      var a = 'img'.allMatches(docu2).length;
     

       for (int i = 0; i < a; i++) {
         
         final e = docu.map((e) => 
         e.getElementsByTagName("img")[i].attributes['src']).toString();
          if (e.contains('files')) {
           String imgurl = 'https://www.twicenest.com/' + e;
           list.insert(i, imgurl);
           }
          else{
            list.insert(i, e);
          } 
            
        }
      list.remove('(/static/blank.gif)');
      final mappedlist = list.asMap();
      print(list);
      print(mappedlist[0]);
      downloadfile(mappedlist[0]);


        
       
      
       
    
}}

   Widget _buildShowUrlBtn() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              var url = await controller.data!.currentUrl();
                makeRequest(url);
                
            },
            child: Icon(Icons.download),
          );
        }
        return Container();
      },
    );
  }
}
    


