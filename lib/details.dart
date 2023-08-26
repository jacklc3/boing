import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
    final List<(String, String)> details;
    final Function setMainState;
    DetailsPage(this.details, this.setMainState);

    @override
    State<DetailsPage> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
    String ftext = "";

    void dialog(int i) {
        showDialog(
            context: context,
            builder: (BuildContext context) => new AlertDialog(
                title: new Text(widget.details[i].$1),
                content: new TextField(
                    onChanged: (String s) { ftext = s; }
                ),
                actions: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.done),
                        onPressed: (){
                            setState((){ widget.details[i] = (widget.details[i].$1, ftext); });
                            widget.setMainState();
                            Navigator.pop(context);
                        }
                    ),
                    new IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: (){ Navigator.pop(context); }
                    ),
                ]
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: new Text("Details")
            ),
            body: new ListView.builder(
                itemCount: widget.details.length,
                itemBuilder: (BuildContext context, int i) {
                    return new ListTile(
                        title: new Text(widget.details[i].$1),
                        subtitle: new Text(widget.details[i].$2),
                        onTap: (){ dialog(i); }
                    );
                }
            )
        );
    }
}
