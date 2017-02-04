source ../lib/see.tcl

namespace eval ::simulation {}

############################################################################
# Client ###################################################################
############################################################################

proc ::simulation::setGlobals {} {
  set ::chan {}
  set ::myname {}
  set ::mymaestro {}
  set ::location "0000"
}


############################################################################
# Run ######################################################################
############################################################################


proc ::simulation::run {} {
  getInput "from user to server message"
  puts $::chan "from $::myname to server message goodmorning"
  flush $::chan
  puts "Server responded: [gets $::chan]"
  #puts "SENDING FIRST [list [list from $::myname to $::mymaestro message 000 when [clock milliseconds]]]"
  #puts $::chan [list [list from $::myname to $::mymaestro message 000 when [clock milliseconds]]]
  #flush $::chan
  puts "Awaiting Instructions from Server..."
  while {1} {
    set msg [gets $::chan]
    puts "received: $msg"
    set sendmsg [::simulation::interpret $msg]
    if {$sendmsg ne ""} {
      #puts "sending: $sendmsg"
      puts $::chan $sendmsg
      flush $::chan
    }
    #after 9000
  }
}


############################################################################
# Helpers ##################################################################
############################################################################

proc ::simulation::getInput {msg} {
  puts "What sense am I? (eg s.1)"
  flush stdout
  set ::myname [gets stdin]
  puts "Who do I talk to? (eg 1.1)"
  flush stdout
  set ::mymaestro [gets stdin]
}


############################################################################
# Processing ###############################################################
############################################################################

proc ::simulation::encode {input} {
  set enc ""
  if {[string match *-* $input] != 0} {
    set enc $::location ;#"000"
  } elseif {$input >9999} {
    set enc $::location ;#"999"
  } elseif {[string length $input] == 3 } {
    set enc "0$input"
  } elseif {[string length $input] == 2 } {
    set enc "00$input"
  } elseif {[string length $input] == 1 } {
    set enc "000$input"
  } else {
    set enc $input
  }
  return $enc
}

proc ::simulation::decode {input} {
  #return [scan $input %d]
  set dec [string trimleft $input 0]
  if {$dec eq ""} { set dec 0 }
  return $dec
}

proc ::simulation::decodeMotor {input} {
  switch -exact $input {
    0 {return 0      }
    1 {return +1     }
    3 {return -1     }
    default {return 0}
  }
#    2 {return +10    }
#    4 {return -10    }
}


proc ::simulation::returnData {input} {
  #puts "location: $location"
  #puts "movement: $input [::enviro::decodeMotor $input]"
  #puts "newinput: [expr $location + [::enviro::decodeMotor $input]]"
  #puts "input $input"
  #puts "input decoded [::simulation::decodeMotor $input]"
  #puts "location $::location"
  #puts "location decoded [::simulation::decode $::location]"
  #puts "location plus input [expr [::simulation::decode $::location] + [::simulation::decodeMotor $input]]"
  #puts "encoded [::simulation::encode [expr [::simulation::decode $::location] + [::simulation::decodeMotor $input]]]"
  set ::location [::simulation::encode [expr [::simulation::decode $::location] + [::simulation::decodeMotor $input]]]
  return [list [list from $::myname to $::mymaestro message $::location when [clock milliseconds]]]
}

proc ::simulation::interpret msg {
  if {[::see::message $msg] eq "_"} {
    return [list "from" $::myname "to" $::mymaestro "message" $::location]
  } else {
    return [::simulation::returnData [::see::message $msg]]
  }
}

############################################################################
# Run ######################################################################
############################################################################

::simulation::setGlobals
set ::chan [socket 127.0.0.1 9900]
#fileevent stdin readable [list userInput]
::simulation::run
