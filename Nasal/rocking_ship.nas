###############################################################################
# rocking_ship.nas by virt_fly
# 2008/12/13
#
# original
#    rocking_nimitz.nas by Tatsuhiro Nishioka
#    - Simulates a brief pitching / rolling deck 
#    2008/07/30
#    Copyright (C) 2008 Tatsuhiro Nishioka (tat dot fgmacosx at gmail dot com)
#    This file is licensed under the GPL license version 2 or later.
# 
################################################################################ 

var limit_pitch = 1;
var limit_roll = 3;
var wind_threshold = 1;

var max_pitch = 2;
var max_roll = 6;
var pitch_cycle = 3;
var roll_cycle = 4;


var calc_angles = func {
    var wind_speed = getprop("/environment/wind-speed-kt");
    if (wind_speed > wind_threshold) {
      #wind_speed = wind_threshold;
    }
    max_pitch = wind_speed / wind_threshold * limit_pitch/10;
    max_roll = wind_speed / wind_threshold * limit_roll/6;
}



var rock_ship = func { 
    calc_angles();
    var sec = getprop("/sim/time/elapsed-sec"); 
    var pitch = math.sin(sec / pitch_cycle * 3.14) * max_pitch;
    var roll = math.sin(sec / roll_cycle * 3.14 ) * max_roll;
    var property_alt=getprop("/position/altitude-ft");
    if (property_alt<9){
    interpolate("/orientation/pitch-deg", pitch, 1); 
    interpolate("/orientation/roll-deg", roll, 1);
    }
    settimer(func { rock_ship(); }, 1 ); 
} 

_setlistener("/sim/signals/fdm-initialized", func { rock_ship(); });

