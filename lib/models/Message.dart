class Message {
  String text;
  String sender;

  Message(this.text, this.sender);

  Message.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        sender = json['sender'];

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender
    };
  }
}