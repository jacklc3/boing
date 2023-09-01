import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
    final List<(String, String)> details;
    final Function setMainState;
    const DetailsPage(this.details, this.setMainState, {super.key});

    @override
    State<DetailsPage> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
    String ftext = "";

    void dialog(int i) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text(widget.details[i].$1),
                content: TextField(
                    onChanged: (String s) { ftext = s; }
                ),
                actions: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.done),
                        onPressed: (){
                            setState((){ widget.details[i] = (widget.details[i].$1, ftext); });
                            widget.setMainState();
                            Navigator.pop(context);
                        }
                    ),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: (){ Navigator.pop(context); }
                    ),
                ]
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text("Details")
            ),
            body: ListView.builder(
                itemCount: widget.details.length,
                itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                        title: Text(widget.details[i].$1),
                        subtitle: Text(widget.details[i].$2),
                        onTap: (){ dialog(i); }
                    );
                }
            )
        );
    }
}
