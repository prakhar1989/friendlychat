import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(FriendlyChatApp());

const String _name = "Prakhar";

// Theme
final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: "FriendlyChat",
        theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme : kDefaultTheme,
        home:  ChatScreen()
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() =>  ChatScreenState();
}

bool isIos(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController =  TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title:  Text("FriendlyChat"),
        elevation: isIos(context) ? 0.0 : 4.0,
      ),
      body:  Container(
        decoration: isIos(context)
            ?  const BoxDecoration(
          border:  Border(top:  BorderSide(color: Colors.grey),
          ),
        ) : null,
        child:  Column(
          children: <Widget>[
             Flexible(
              child:  ListView.builder(
                padding:  EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
             Divider(height: 1.0),
             Container(
              decoration:  BoxDecoration(color: Theme.of(context).cardColor),
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

    var iOSButton = CupertinoButton(
        child: Text("Send"),
        onPressed: pressedHandler,
    );

    var iconButton = IconButton(
        icon: Icon(Icons.send),
        onPressed: pressedHandler,
    );

    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onChanged: (String text) {
                      setState(() {
                        _isComposing = text.isNotEmpty;
                      });
                    },
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration.collapsed(hintText: "Send a message"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: isIos(context) ? iOSButton : iconButton,
                )
              ],
            )
        )
    );
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) { return; }
    _textController.clear();
    setState(() {_isComposing = false; });
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
          duration: Duration(milliseconds: 150),
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

  ChatMessage({required this.text, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor:  CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child:  Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
               Container(
                margin: const EdgeInsets.only(right: 16.0),
                child:  CircleAvatar(
                    child:  Text(_name[0]),
                    backgroundColor: Theme.of(context).accentColor,
                ),
              ),
               Expanded(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                     Text(_name, style: Theme.of(context).textTheme.bodyLarge),
                     Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child:  Text(text),
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