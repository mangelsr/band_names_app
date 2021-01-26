import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  _handleActiveBands(dynamic data) {
    this.bands = (data as List).map((e) => Band.fromMap(e)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          this.bands.isNotEmpty ? _buildGraph() : Container(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (_, int i) => _buildBandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _buildBandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
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
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
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
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'bandName': bandName});
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

  Widget _buildGraph() {
    final Map<String, double> dataMap = Map();
    bands.forEach((Band band) =>
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));
    return PieChart(dataMap: dataMap);
  }
}
