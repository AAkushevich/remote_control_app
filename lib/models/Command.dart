class Command {
  String type;
  Coords startCoords;
  Coords endCoords;

  Command(this.type, this.startCoords, this.endCoords);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'startCoords': startCoords.toJson(),
      'endCoords': endCoords.toJson(),
    };
  }
}

class Coords {
  double x;
  double y;

  Coords(this.x, this.y);

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}