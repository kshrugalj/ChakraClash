// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  static WebSocketChannel? _channel;

  static void connect() {
    //Do not use UARK Guest
    print('Connecting to ws://127.0.0.1:8765...');
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8765'),
    );

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final accuracy = data['accuracy'];
        print('Accuracy: $accuracy%');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }


  static void sendImage(String base64Image) {
    if (_channel != null) {
      final jsonData = jsonEncode({'image': base64Image});
      _channel!.sink.add(jsonData);
    }
  }

  static void disconnect() {
    _channel?.sink.close();
  }
}
