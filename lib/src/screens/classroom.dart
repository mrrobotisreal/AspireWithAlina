import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../navigation/side_navigation_menu.dart';

class Classroom extends StatefulWidget {
  const Classroom({
    super.key,
  });

  static const String routeName = '/classroom';

  @override
  _ClassroomState createState() => _ClassroomState();
}

class _ClassroomState extends State<Classroom> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:9999/video"),
  );
  late RTCPeerConnection _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _setupWebSocket();
    _createPeerConnection();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _setupWebSocket() {
    _channel.stream.listen((message) async {
      var data = jsonDecode(message);
      switch (data['type']) {
        case 'offer':
          await _peerConnection.setRemoteDescription(
            RTCSessionDescription(data['data']['sdp'], data['data']['type']),
          );
          var answer = await _peerConnection.createAnswer();
          await _peerConnection.setLocalDescription(answer);
          _channel.sink.add(jsonEncode({'type': 'answer', 'data': answer.toMap()}));
          break;
        case 'answer':
          await _peerConnection.setRemoteDescription(
            RTCSessionDescription(data['data']['sdp'], data['data']['type']),
          );
          break;
        case 'candidate':
          await _peerConnection.addCandidate(
            RTCIceCandidate(
              data['data']['candidate'],
              data['data']['sdpMid'],
              data['data']['sdpMLineIndex'],
            ),
          );
          break;
      }
    });
  }

  Future<void> _createPeerConnection() async {
    var configuration = {
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
    };
    _peerConnection = await createPeerConnection(configuration);

    var localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = localStream;
    localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, localStream);
    });

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate != null) {
        _channel.sink.add(jsonEncode({
          'type': 'candidate',
          'data': candidate.toMap(),
        }));
      }
    };

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };
  }

  Future<void> _startCall() async {
    var offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    _channel.sink.add(jsonEncode({'type': 'offer', 'data': offer.toMap()}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromARGB(150, 126, 126, 126),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            elevation: 24,
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Classroom',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Bauhaus',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
                decorationColor: Colors.white,
              ),
            ),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
        ),
      ),
      drawer: const SideNavigationMenu(),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          Expanded(
            child: RTCVideoView(_localRenderer, mirror: true,),
          ),
          ElevatedButton(
            onPressed: _startCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
            child: Text(
              'Start Call',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: 'Bauhaus',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
