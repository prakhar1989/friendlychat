import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(new FriendlyChatApp());

const String _name = "Prakhar";

// Theme
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "FriendlyChat",
        theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme : kDefaultTheme,
        home: new ChatScreen()
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

bool isIos(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("FriendlyChat"),
        elevation: isIos(context) ? 0.0 : 4.0,
      ),
      body: new Container(
        decoration: isIos(context)
            ? new BoxDecoration(
          border: new Border(top: new BorderSide(color: Colors.grey[200]),
          ),
        ) : null,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (ChatMessage msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

  Widget _buildTextComposer() {
    var pressedHandler = _isComposing
        ? () => _handleSubmitted(_textController.text)
        : null;

    var iOSButton = new CupertinoButton(
        child: new Text("Send"),
        onPressed: pressedHandler,
    );

    var iconButton = new IconButton(
        icon: new Icon(Icons.send),
        onPressed: pressedHandler,
    );

    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onChanged: (String text) {
                      setState(() {
                        _isComposing = text.length > 0;
                      });
                    },
                    onSubmitted: _handleSubmitted,
                    decoration: new InputDecoration.collapsed(hintText: "Send a message"),
                  ),
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: isIos(context) ? iOSButton : iconButton,
                )
              ],
            )
        )
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {_isComposing = false; });
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
          duration: new Duration(milliseconds: 150),
          vsync: this
      ),
    );
    setState(() { _messages.insert(0, message); });
    message.animationController.forward();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;

  ChatMessage({this.text, this.animationController});

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: new CircleAvatar(
                    child: new Text(_name[0]),
                    backgroundColor: Theme.of(context).accentColor,
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(_name, style: Theme.of(context).textTheme.subhead),
                    new Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: new Text(text),
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
