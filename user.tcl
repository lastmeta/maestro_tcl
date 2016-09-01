source lib/see.tcl

namespace eval ::user {}
namespace eval ::user::helpers {}


############################################################################
# Client ###################################################################
############################################################################


proc ::user::setGlobals {} {
  set ::chan {}
}

proc ::user::run {} {
  puts $::chan "from user to server message goodmorning"
  flush $::chan
  puts "Server responded: [gets $::chan]"
  puts "Awaiting Instructions from Server..."
  puts "what do you want to say?"
  while {1} {
    set input [::user::helpers::getInput]

    if {[::see::contents $input] eq ""} {
      set input [list "from" "user" "to" "server" "command" [lindex $input 0] "message" [lrange $input 1 end]]
    }

    if {$input eq "from user to server command help message {}"  ||
        $input eq "from user to server command ? message {}"     ||
        $input eq "from user to server command man message {}"
    } then {
      ::user::helpers::displayHelp
    } else {
      puts $::chan [dict replace $input when [clock milliseconds]]
      flush $::chan
      puts [gets $::chan]
    }
  }
}

############################################################################
# Helpers ##################################################################
############################################################################

proc ::user::helpers::getInput {} {
  flush stdout
  set line [gets stdin]
  return $line
}

proc ::user::helpers::displayHelp {} {
  puts ""
  puts "############################ Help ############################"
  puts ""
  puts "COMMAND DATA"
  puts ""
  puts "goal DATA   give Maestro a goal (hierarchy)"
  puts "try  DATA   give Maestro a goal (flat)"
  puts "can  DATA   ask the system if it can achieve a goal"
  puts "sleep       stop actions and process memory to generate intuition."
  puts ""
  puts "COMMAND SUBCOMMANDS"
  puts ""
  puts "goal  _      tell Maestro to explore (hierarchy)"
  puts "goal  __     tell Maestro to stop (hierarchy)"
  puts "try   _      tell Maestro to explore (flat)"
  puts "try   __     tell Maestro to stop (flat)"
  puts "sleep acts   tell Maestro to explore what actions are useful"
  puts "sleep opps   tell Maestro to find and extrapolate opposite actions"
  puts "acts  INTS   tell Maestro to use only this list of actions ie. 1 2 3"
  puts "limit INT    sets the limit of learning; lower is faster. 1 - 10"
  puts "cells INT    sets the number of cells per node; 1 - 10. Not advised"
  puts "from user to s.1 message _ tells simulation to tell naisen its location"
  puts ""
  puts "############################ end ############################"
  puts ""
}


############################################################################
# Run ######################################################################
############################################################################


set ::chan [socket 127.0.0.1 9900]
::user::run
vwait forever
