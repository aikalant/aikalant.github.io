import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocketChannel channel;
  late final ValueNotifier<double> notifier = ValueNotifier<double>(50);
  bool changing = false;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    channel = connect(true);
  }

  WebSocketChannel connect([bool firstTime = false]) {
    if (!firstTime) {
      channel.sink.close();
      connected = false;
    }
    final c = WebSocketChannel.connect(
      Uri.parse(
        'ws://68.6.165.178:18232',
      ),
    );
    connected = true;
    //print('socket connected');
    c.stream.listen((dynamic event) {
      final temp = double.tryParse(event);
      print('recv event: ${DateTime.now()}');
      if (!changing && temp != null) {
        notifier.value = temp;
      }
    }, onDone: () {
      print('done');
      connected = false;
    }, onError: (Object error) {
      print('error: ${error.toString()}');
      connected = false;
    });
    return c;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Socket Client',
          ),
        ),
        body: ValueListenableBuilder<double>(
            valueListenable: notifier,
            builder: (context, temp, _) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(temp.toStringAsFixed(1), style: const TextStyle(fontSize: 50)),
                      Slider(
                        value: temp,
                        min: 10.0,
                        max: 90.0,
                        onChangeStart: (_) => changing = true,
                        onChangeEnd: (_) => changing = false,
                        onChanged: (newTemp) {
                          notifier.value = newTemp;
                          if (connected) {
                            channel.sink.add(newTemp.toString());
                            print('sent event: ${DateTime.now()}');
                          }
                        },
                        label: temp.toString(),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
