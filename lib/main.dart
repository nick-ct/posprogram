import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  void initState() {
    super.initState();

    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));

    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found ${devices.length}');
      if (devices.length > 0)
        setState(() {
          _devices = devices;
        });
    });
  }

  void _stopScanDevices(){
    printerManager.stopScan();
  }

  Ticket testTicket() {
    final Ticket ticket = Ticket(PaperSize.mm58);

    ticket.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: PosCodeTable.westEur));
    ticket.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: PosCodeTable.westEur));

    ticket.text('Bold text', styles: PosStyles(bold: true));
    ticket.text('Reverse text', styles: PosStyles(reverse: true));
    ticket.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    ticket.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    ticket.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    ticket.feed(2);
    ticket.cut();
    ticket.drawer();
    return ticket;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    // DEMO RECEIPT
    final PosPrintResult res = await printerManager.printTicket(testTicket());

    print(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: <Widget>[
          FlatButton(
            onPressed: () {
              print("scan");
              _startScanDevices();
            },
            child: Text("Scan"),
          ),
          FlatButton(
            onPressed: () {
              print("stop scan");
              _stopScanDevices();
            },
            child: Text("Stop Scan"),
          ),
          Container(
            height: 600,
            child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => _testPrint(_devices[index]),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.print),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(_devices[index].name ?? ''),
                                    Text(_devices[index].address),
                                    Text(
                                      'Click to print a test receipt',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  );
                }),
          ),
        ]));
  }
}
