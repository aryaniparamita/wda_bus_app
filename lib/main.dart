import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:wda_bus_app/CustomTimerPainter.dart';
import 'BusRetrievalController.dart';
import 'CustomTimerPainter.dart';

import 'package:wda_bus_app/BusDetails.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Lazy Bus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyGmapApp(title: 'My Lazy Bus'),
    );
  }
}

class MyGmapApp extends StatefulWidget {
  MyGmapApp({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyGmapApp> with TickerProviderStateMixin {
  GoogleMapController mapController;
  DateTime dateTime;
  String source;
  String destination;
  bool callback = false;
  BusDetails busDetails = new BusDetails();
  Future<BusDetails> b;
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  AnimationController controller;
  Animation<double> animation;

  String get timerString {
    Duration duration = controller.duration * controller.value ;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget timerStringC(Duration dur){
    Duration duration = new Duration(
//        minutes : (dur.inMinutes * controller.value).toInt(),
                                      seconds : ((dur.inSeconds * controller.value)).toInt()) ;
    String caption =  '${duration.inMinutes}:${(duration.inSeconds%60).toString().padLeft(2, '0')}';

    return new Text(caption, style: TextStyle(
        fontSize: 60.0,
        color: Colors.black54));
  }


  @override
  void initState() {
    super.initState();
    sourceController = TextEditingController(text: "310171");
    destinationController = TextEditingController(text: "MBFC Tower 1");
    arrivalController = TextEditingController(text: "1:13 PM");
    controller =  AnimationController(duration: Duration(seconds: 10000), vsync: this);

  }

  void setDate(DateTime dateTime){
    this.dateTime = dateTime;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('LazyBus'),
              leading: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Icon(
                    FontAwesomeIcons.bus
                ),
              ),
              backgroundColor: Colors.green[700],
            ),
            body: Container(
                width: MediaQuery.of(context).size.width,
                child : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:<Widget>[
                      Expanded(
                          child:
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Enter Source',
                                prefixIcon: Icon(FontAwesomeIcons.home)
                            ),
                            controller: sourceController,
                          ))
                      ,Expanded(
                          child:
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Enter Destination',
                                prefixIcon: Icon(FontAwesomeIcons.building)
                            ),
                            controller: destinationController,
                          ))
                      ,
                      DateTimePickerC(),
                      RaisedButton(
                        onPressed: () async{
                          print (dateTime);
                          print(destinationController.text);
                          print(sourceController.text);
                          Future<BusDetails> b = findMyBus(sourceController.text, destinationController.text, dateTime);
                          // Make API request based on this input
                          await b.then((value) {
                            setState(() {
                              callback = true;
                              busDetails = value;
                              print(busDetails);

                            });
                          });
                          print (busDetails.durationhhmm());
                            controller.reset();
                            controller.reverse(
                                from: controller.value == 0.0
                                    ? 1.0
                                    : controller.value);
                          Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(8.0),
                            width: MediaQuery.of(context).size.width*0.95,
                            decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide( //                   <--- left side
                                    color: Colors.blueAccent,
                                    width: 3.0,
                                  )),
                            ),
                            child: Text(" asdfasdf Board bus " + busDetails.bus_number +
                                " \nfrom bus stop " +busDetails.busstop_name +
                                ".\nBus depart at : "+
                                busDetails.bus_departure_time + "\n"+
                                "Journey will take "+ busDetails.durationhhmm()),
                          );
                        }

                        ,
                        child: Text(
                            "Find My Bus"
                        ),
                      ),

                      FutureBuilder<BusDetails>(
                          future: findMyBus(sourceController.text, destinationController.text, dateTime),
                          builder: (context, AsyncSnapshot<BusDetails> snapshot) {
                            if (snapshot.hasData){
                              return new Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(15.0),
                                    padding: const EdgeInsets.all(8.0),
                                    width: MediaQuery.of(context).size.width*0.95,
                                    decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide( //
                                            color: Colors.blueAccent,
                                            width: 3.0,
                                          )),
                                    ),
                                    child: Text("Board bus " + snapshot.data.bus_number +
                                        " \nfrom bus stop " +snapshot.data.busstop_name +
                                        ".\nBus depart at : "+
                                        snapshot.data.bus_departure_time + "\n"+
                                        "Journey will take "+ snapshot.data.durationhhmm()),
                                  ),
                                      Container(
                                        height:200,
                                        child: Align(
                                          alignment: FractionalOffset.center,
                                          child: AspectRatio(
                                            aspectRatio: 1.0,
                                            child: Stack(
                                              children: <Widget>[
                                                Positioned.fill(
                                                  child: CustomPaint(
                                                      painter: CustomTimerPainter(
                                                        animation: controller,
                                                        backgroundColor: Colors.white,
                                                        color: themeData.indicatorColor,
                                                      )),
                                                ),
                                                Align(
                                                  alignment: FractionalOffset.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text(
                                                        "Bus Coming In ...",
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.black54),
                                                      ),
                                                      AnimatedBuilder(
                                                          animation: controller,
                                                          builder: (context,child) {
                                                            return timerStringC(snapshot.data.gap_to_leave());
                                                          }
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                //  CountDownTimer(snapshot.data.duration)

                              );


                            }
                            else{
                              return Text('');
                            }
                          }

                      )

                    ])

            )));
  }
}









class DateTimePickerC extends StatefulWidget {
  @override
  _DateTimePickerC createState() => _DateTimePickerC();
}

class _DateTimePickerC extends State<DateTimePickerC> {
  String _time = "Not set";

  @override
  void initState() {
    super.initState();
  }
  @override
  String rightDivider() => "";

  @override
  List<int> layoutProportions() => [100, 100, 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width:  MediaQuery.of(context).size.width,
                child:Text ('Arrival Time', textAlign: TextAlign.left,),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      theme: DatePickerTheme(
                        containerHeight: 210.0,
                      ),
                      showTitleActions: true, onConfirm: (time) {
                        _time = '${time.hour} : ${time.minute} ';
                        setState(() {});
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                  setState(() {});
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.access_time,
                                  size: 18.0,
                                ),
                                Text(
                                  " $_time",
                                  style: TextStyle(
                                      fontSize: 16.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        "  Change",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

