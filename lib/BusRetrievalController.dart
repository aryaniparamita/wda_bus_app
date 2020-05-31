import 'BusDetails.dart';
import 'GoogleMapsKey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<BusDetails> findMyBus(source, destination, dateTime) async {
  Future<String> sourcePlaceId, destinationPlaceId;
  sourcePlaceId = retrievePlace(source);
  Future<BusDetails> b ;
  if (dateTime==null){
    dateTime = new DateTime.now().add(Duration(minutes:3));
  }
  int dateTimeUTC = (dateTime.toUtc().millisecondsSinceEpoch~/1000);
  await sourcePlaceId.then((sourceResult) async{
    destinationPlaceId = retrievePlace(destination);
    await destinationPlaceId.then((destinationResult) async {
      //send retrieve bus and travelling time
      b = retrieveBus(sourceResult,destinationResult, dateTimeUTC);
      await b.then((value) {
      });
      return b;

    });
  } );
  return b;

}

Future <BusDetails> retrieveBus(source,destination, dateTime) async{
  BusDetails b = new BusDetails();
  bool transit_checker = false;
  if ((source!=null) && (destination!=null)){
    String url = 'https://maps.googleapis.com/maps/api/directions/json?&mode=transit'+
        '&origin=place_id:'+source+
        '&destination=place_id:'+destination+
        '&key='+ GoogleMapsKey() + //retrieve your own key from GCP platform
        '&region=sg'+
        '&departure_time='+dateTime.toString()
        +'&transit_mode=bus&simplify=TRUE';
    print (url);
    var response = await http.get(Uri.encodeFull(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      Map<String, dynamic> parsedJson = json.decode(response.body);
      if (parsedJson['routes'].length > 0) {
        b.duration = parsedJson['routes'][0]['legs'][0]['duration']['value'];
        var steps = (parsedJson['routes'][0]['legs'][0]['steps']);
        steps.forEach((step) {
          if (transit_checker==false){
          if (step['travel_mode'] == 'TRANSIT') {
            transit_checker = true;
            b.busstop_name =
            (step['transit_details']['departure_stop']['name']);
            b.bus_number = (step['transit_details']['line']['name']);
            b.bus_departure_time =
            (step['transit_details']['departure_time']['text']);
            b.bus_departure_time_value =
            (step['transit_details']['departure_time']['value']);
          }
          }
        });
        if (b.bus_number != null) {
          return b;
        }
      }
    }
    return null;
  }
  else{
    return null;
  }
}

Future<String> retrievePlace(place) async{
  if (place!=null){
    String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query='+
        place+
        '&key='+ GoogleMapsKey() +
        '&region=sg';
    var response = await http.get(Uri.encodeFull(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> parsedJson = json.decode(response.body);
      if (parsedJson['results'].length>0) {
        return parsedJson['results'][0]['place_id'];
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }
  else{
    return null;
  }
}
