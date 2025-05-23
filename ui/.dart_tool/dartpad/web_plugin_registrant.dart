// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:camera_web/camera_web.dart';
import 'package:flutter_inappwebview_web/web/main.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  CameraPlugin.registerWith(registrar);
  InAppWebViewFlutterPlugin.registerWith(registrar);
  FlutterTtsPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
