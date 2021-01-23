import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'RHCP', votes: 20),
    Band(id: '2', name: 'Artic Monkeys', votes: 10),
    Band(id: '3', name: 'Los Bunkers', votes: 15),
    Band(id: '4', name: 'System of Dawn', votes: 18),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (_, int i) => _buildBandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _buildBandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        // TODO: Call delete on server...
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2).toUpperCase()),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        onTap: () => print(band.name),
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      showMaterialInputDialog(textController);
    } else if (Platform.isIOS) {
      showCupertinoInputDialog(textController);
    }
  }

  void _addBand(String bandName) {
    if (bandName.length > 1) {
      bands.add(Band(
        id: (bands.length + 1).toString(),
        name: bandName,
        votes: 0,
      ));
    }
    Navigator.pop(context);
  }

  void showMaterialInputDialog(TextEditingController textController) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('New band name'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            child: Text('ADD'),
            elevation: 5,
            textColor: Colors.blue,
            onPressed: () => _addBand(textController.text),
          )
        ],
      ),
    );
  }

  void showCupertinoInputDialog(TextEditingController textController) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('New band name'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Close'),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text('Add'),
            isDefaultAction: true,
            onPressed: () => _addBand(textController.text),
          ),
        ],
      ),
    );
  }
}
