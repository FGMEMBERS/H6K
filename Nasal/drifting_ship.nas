###############################################################################
# drifting_ship.nas by virt_fly
# 2008/12/13
#
################################################################################ 

var wind_threshold = 20;
var latche=1;
var lonche=1;
var wind_dir=0;

var calc_drift = func {
    var wind_speed = getprop("/environment/wind-speed-kt");
      #print ("wind_speed:" , wind_speed);
    if (wind_speed > wind_threshold) {
      wind_speed = wind_threshold;
    }
    var wind_dir = getprop("/environment/wind-from-heading-deg");
    var drift_dir=wind_dir+180;
    if (drift_dir >=360) {
      drift_dir = drift_dir-360;
    }
      print ("wind_dir;" ,wind_dir , " drift_dir;", drift_dir);
    latche = math.cos(drift_dir*math.pi / 180.0)*(wind_speed/50000);
    lonche = math.sin(drift_dir*math.pi / 180.0)*(wind_speed/50000);       
      #print ("latche:" , latche," lonche:",lonche);
}
  
var drift_ship = func { 
    calc_drift();
    var sec = getprop("/sim/time/elapsed-sec"); 
    var property_lat=getprop("/position/latitude-deg");
    if (property_lat==nil){
     var oldlat=0;
    }else{
     var oldlat=getprop("/position/latitude-deg");
    }
    var property_lon=getprop("/position/longitude-deg");
    if (property_lon==nil){
     var oldlon=0;
    }else{
     var oldlon=getprop("/position/longitude-deg");
    }
    var newlat = latche*360.0/40000000+oldlat;
    var newlon = lonche*360.0/(math.cos(newlat*math.pi / 180.0)*40000000)+oldlon;
    var property_alt=getprop("/position/altitude-ft");
    var property_speed=getprop("/velocities/airspeed-kt");
    if (property_alt<7 and property_speed<10){
    interpolate("/position/latitude-deg", newlat, 1); 
    interpolate("/position/longitude-deg", newlon, 1); 
    #interpolate("/orientation/heading-deg", wind_dir, 1); 
    }
    settimer(func { drift_ship(); }, 1 ); 
} 

_setlistener("/sim/signals/fdm-initialized", func { drift_ship(); });

