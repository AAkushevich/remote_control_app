import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/models/Command.dart';
import 'package:remote_control_app/models/DeviceInfo.dart';
import 'package:remote_control_app/models/Message.dart';
import 'package:remote_control_app/utils/Logger.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class WebRTCService {
  WebRTCService(
      this.clientConnectedCallback,
      this.connectionCanceledEvent,
      this.commandReceived);

  Function() clientConnectedCallback;
  Function() connectionCanceledEvent;
  Function(String command) commandReceived;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;
  RTCDataChannel? remoteCommandChannel;
  late DeviceInfo _deviceInfo;

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    FirebaseFirestore firestoreDb = FirebaseFirestore.instance;
    DocumentReference roomRef = firestoreDb.collection('rooms').doc();

    Logger.Green.log(
        'Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      Logger.Green.log('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    initRemoteControlChannel();

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    Logger.Green.log('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;
    Logger.Green.log('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    peerConnection?.onTrack = (RTCTrackEvent event) {
      clientConnectedCallback();
      Logger.Green.log('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        Logger.Green.log('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);

      });
    };

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      // Listen for remote Ice candidates below
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          Logger.Green.log('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    roomRef.snapshots().listen((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        Logger.Blue.log("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
        await peerConnection?.getRemoteDescription();
      }
    });

    return roomId;
  }

  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteVideo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();
    Logger.Green.log('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      Logger.Green.log(
          'Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);
      peerConnection?.onDataChannel = (RTCDataChannel? channel) {
        if (channel != null) {
          remoteCommandChannel ??= channel;
          remoteCommandChannel
              ?.send(RTCDataChannelMessage("info:${_deviceInfo.toJson()}"));

          channel.onMessage = (RTCDataChannelMessage message) {
            // Set up event listener for the data channel
            Logger.Magenta.log(message.text);
            commandReceived(message.text);
          };
        }
      };
      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          Logger.Green.log('onIceCandidate: complete!');
          return;
        }
        Logger.Blue.log('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      var data = roomSnapshot.data() as Map<String, dynamic>;
      Logger.Blue.log('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      Logger.Green.log('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);

      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var document in snapshot.docChanges) {
          var data = document.doc.data() as Map<String, dynamic>;
          Logger.Green.log("JOINED TO ROOM");
          Logger.Green.log('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    }
  }

  Future<void> openUserMedia(
      // 3.openUserMedia
      RTCVideoRenderer localVideo,
      RTCVideoRenderer remoteVideo) async {
    var stream = await navigator.mediaDevices.getDisplayMedia({
      'video': {
        'mediaSource': 'screen',
      },
    });

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    // 4. hangUp
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      for (var document in calleeCandidates.docs) {
        document.reference.delete();
      }

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      for (var document in callerCandidates.docs) {
        document.reference.delete();
      }

      await roomRef.delete();
    }

/*    localStream?.dispose();
    remoteStream?.dispose();*/
  }

  void initRemoteControlChannel() async {
    RTCDataChannelInit dataChannelInit = RTCDataChannelInit();
    dataChannelInit.ordered = true;

    remoteCommandChannel = await peerConnection?.createDataChannel(
        'remote-control-channel', dataChannelInit);

    remoteCommandChannel?.onDataChannelState = (RTCDataChannelState state) {
      Logger.Magenta.log(state.toString());
    };

    remoteCommandChannel?.onMessage = (RTCDataChannelMessage message) {
      Logger.Magenta.log(message.text);
      commandReceived(message.text);
    };
  }

  void sendRemoteControlCommand(Command command) {
    if (remoteCommandChannel != null) {
      remoteCommandChannel
          ?.send(RTCDataChannelMessage("command:${command.toJson()}"));
    } else {
      Logger.Magenta.log("dataChannel is null");
    }
  }

  void sendDeviceInfo(DeviceInfo deviceInfo) {
    _deviceInfo = deviceInfo;
  }

  void sendMessageToRemoteDevice(Message message) {
    if (remoteCommandChannel != null) {
      remoteCommandChannel
          ?.send(RTCDataChannelMessage("message:${message.toJson()}"));
    } else {
      Logger.Magenta.log("dataChannel is null");
    }
  }

  void registerPeerConnectionListeners() {
    // 5.registerPeerConnectionListeners

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      Logger.Magenta.log('TRIGGERRED onIceGatheringState ');
      Logger.Blue.log('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      Logger.Magenta.log('TRIGGERRED onConnectionState');
      Logger.Blue.log('ICE gathering state changed $state');
      if(state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {

      } else if(state == RTCPeerConnectionState.RTCPeerConnectionStateFailed){
        connectionCanceledEvent();
        Logger.Red.log('FAILED TO CONNECT');
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      Logger.Magenta.log('TRIGGERRED onSignalingState');
      Logger.Blue.log('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      Logger.Magenta.log('TRIGGERRED onIceGatheringState');
      Logger.Blue.log('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      Logger.Magenta.log('TRIGGERRED onAddStream');
      Logger.Blue.log("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
