import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../universal_ble.dart';

class UniversalBlePlus{



  static set queueType(QueueType queueType)=>UniversalBle.queueType =queueType;
  static set timeout(Duration timeout)=>UniversalBle.timeout =timeout;

  static StreamController<Map<String,dynamic>> streamController = StreamController.broadcast(sync: false);

  static Future<void> startScan({ScanFilter? scanFilter, PlatformConfig? platformConfig}) async {
    await UniversalBle.startScan(scanFilter:scanFilter,platformConfig:platformConfig);
  }
  static Future<void> stopScan({ScanFilter? scanFilter, PlatformConfig? platformConfig}) async {
    await UniversalBle.startScan(scanFilter:scanFilter,platformConfig:platformConfig);
  }

  static Future<BleDevice?> connect(String deviceId, {Duration? connectionTimeout}) async {
    final completer = Completer<BleDevice>();
    final state=await UniversalBle.getConnectionState(deviceId);
    if(state == BleConnectionState.disconnected){
      streamController.stream
      .where((event)=>event.containsKey('connectionChange'))
      .map<Map<String, dynamic>>((convert)=> convert['connectionChange'])
      .listen((data){
        if(data['deviceId'] == deviceId){
          if(data['error'] != null){
            completer.completeError(data['error']);
          }else if(data['isConnected']){
            UniversalBle.getSystemDevices().then((devs){
              final dev=devs.firstWhereOrNull((dev)=>dev.deviceId == deviceId);
              if(dev != null){
                completer.complete(dev);
              }
            });
          }else{
            completer.completeError('unable to connect $deviceId');
          }
        }
      });
      UniversalBle.connect( deviceId, connectionTimeout: connectionTimeout);
    }else{
      completer.completeError('device state is $state');
    }
    return Future.value();
  }

  static initilize() {
    UniversalBle.onScanResult= (bleDevice) {
      streamController.add({'scanResult':bleDevice});
    };
    UniversalBle.onConnectionChange = (String deviceId, bool isConnected, String? error) {
      streamController.add({'connectionChange':{
        'deviceId':deviceId,
        'isConnected':isConnected,
        'error':error,
      }});
    };
    UniversalBle.onAvailabilityChange = (AvailabilityState state) {
      streamController.add({'availabilityChange':state});
    };
    UniversalBle.onPairingStateChange=(String deviceId, bool paired){
      streamController.add({'pairingStateChange': {
        'deviceId':deviceId,
        'paired':paired,
      }});
    };

    UniversalBle.onQueueUpdate=(String id, int remainingQueueItems){
      streamController.add({'pairingStateChange': {
        'id':id,
        'remainingQueueItems':remainingQueueItems,
      }});
    };

    UniversalBle.onValueChange = (String deviceId, String characteristicId, Uint8List value){
      streamController.add({'pairingStateChange': {
        'deviceId':deviceId,
        'characteristicId':characteristicId,
        'value': value
      }});
    };

  }
}