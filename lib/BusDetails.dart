import 'dart:math' as math;
class BusDetails{
  int duration;
  String busstop_name;
  String bus_number;
  String bus_departure_time;
  int bus_departure_time_value;

  String durationhhmm(){
      int hour = (duration/3600).floor();
      int min = ((duration%3600)/60).floor();
      int sec = ((duration%60)).floor();
      String durationhhmm = "";
      if (hour>0){
        durationhhmm += hour.toString() + "h ";
      }
      if (min>0){
        durationhhmm += min.toString() + "m ";
      }

      return durationhhmm+sec.toString()+ "s";

  }
  Duration gap_to_leave(){
    DateTime now = new DateTime.now();
    DateTime busDeparture = new DateTime.fromMillisecondsSinceEpoch(bus_departure_time_value*1000);
    Duration difference = busDeparture.difference(now);
    return difference;

  }
}