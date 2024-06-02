class DeviceInfo {
  String device;
  String model;
  String manufacturer;
  String androidVersion;
  String hardware;
  String display;

  DeviceInfo(
      this.device, this.model, this.manufacturer, this.androidVersion, this.hardware, this.display);

  DeviceInfo.fromJson(Map<String, dynamic> json)
      : device = json['device'],
        model = json['model'],
        manufacturer = json['manufacturer'],
        androidVersion = json['androidVersion'].toString(),
        hardware = json['hardware'],
        display = json['display'];

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'model': model,
      'manufacturer': manufacturer,
      'androidVersion': androidVersion,
      'hardware': hardware,
      'display': display,
    };
  }
}
