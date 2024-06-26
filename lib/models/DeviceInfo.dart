class DeviceInfo {
  String device;
  String model;
  String manufacturer;
  String androidVersion;
  String totalMemory;
  String usedMemory;
  String buildNumber;
  String processorName;
  String processorManufacturer;
  int apiLevel;

  DeviceInfo(
      this.device,
      this.model,
      this.manufacturer,
      this.androidVersion,
      this.totalMemory,
      this.usedMemory,
      this.buildNumber,
      this.processorName,
      this.processorManufacturer,
      this.apiLevel);

  DeviceInfo.fromJson(Map<String, dynamic> json)
      : device = json['device'],
        model = json['model'],
        manufacturer = json['manufacturer'],
        androidVersion = json['androidVersion'].toString(),
        totalMemory = json['totalMemory'].toString(),
        usedMemory = json['usedMemory'].toString(),
        buildNumber = json['buildNumber'].toString(),
        processorName = json['processorName'] ?? "Unknown",
        processorManufacturer = json['processorManufacturer'] ?? "Unknown",
        apiLevel = json['apiLevel'] != null ? json['apiLevel'].toInt() : 0;

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'model': model,
      'manufacturer': manufacturer,
      'androidVersion': androidVersion,
      'totalMemory': totalMemory,
      'usedMemory': usedMemory,
      'buildNumber': buildNumber,
      'processorName': processorName,
      'processorManufacturer': processorManufacturer,
      'apiLevel': apiLevel,
    };
  }
}
