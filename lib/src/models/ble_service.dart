import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:universal_ble/universal_ble.dart';
class BleService {
  late String uuid;
  List<BleCharacteristic> characteristics;

  BleService(String uuid, this.characteristics) {
    this.uuid = BleUuidParser.string(uuid);
  }
  @override
  String toString() {
    return 'BleService{uuid: $uuid, characteristics: $characteristics}';
  }
}

class BleCharacteristic {
  late String uuid;
  String deviceId;
  String service;
  List<CharacteristicProperty> properties;

  bool hasProperty(CharacteristicProperty property)=>properties.firstWhereOrNull((p)=>p==property) != null;
  BleCharacteristic(String uuid, this.properties, this.deviceId, this.service) {
    this.uuid = BleUuidParser.string(uuid);
    
  }
  Future<void> setNotify(bool value) async {
    if(hasProperty(CharacteristicProperty.broadcast) != value){
      if (hasProperty(CharacteristicProperty.indicate)) {
        await UniversalBle.setNotifiable(deviceId, service, uuid, value ? BleInputProperty.indication : BleInputProperty.disabled);
      } else if (hasProperty(CharacteristicProperty.notify)) {
        await UniversalBle.setNotifiable(deviceId, service, uuid, value ? BleInputProperty.notification : BleInputProperty.disabled);
      }else{
        throw Exception('Characteristic does not support notify or indicate');
      }
    }else{
      throw Exception('Characteristic already has the specified property');
    }
  }
  Future<Uint8List> readValue([Duration? timeout]) async {
    return await UniversalBle.readValue(deviceId, service, uuid, timeout: timeout);
  }
  Future<void> writeValue(Uint8List value) async {
    return await UniversalBle.writeValue(deviceId, service, uuid, value, hasProperty(CharacteristicProperty.writeWithoutResponse) ? BleOutputProperty.withoutResponse : BleOutputProperty.withResponse );
  }

  

  @override
  String toString() {
    return 'BleCharacteristic{uuid: $uuid, properties: $properties}';
  }
}

enum CharacteristicProperty {
  broadcast,
  read,
  writeWithoutResponse,
  write,
  notify,
  indicate,
  authenticatedSignedWrites,
  extendedProperties;

  const CharacteristicProperty();

  factory CharacteristicProperty.parse(int index) =>
      CharacteristicProperty.values[index];

  @override
  String toString() => name;
}
