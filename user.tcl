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
    } elseif {$input eq "from user to server command help message help"    } {
      ::user::helpers::displayHelpForHelp
    } elseif {$input eq "from user to server command help message explore" } {
      ::user::helpers::displayHelpForExplore
    } elseif {$input eq "from user to server command help message stop"    } {
      ::user::helpers::displayHelpForStop
    } elseif {$input eq "from user to server command help message do"      } {
      ::user::helpers::displayHelpForDo
    } elseif {$input eq "from user to server command help message try"     } {
      ::user::helpers::displayHelpForTry
    } elseif {$input eq "from user to server command help message can"     } {
      ::user::helpers::displayHelpForCan
    } elseif {$input eq "from user to server command help message sleep"   } {
      ::user::helpers::displayHelpForSleep
    } elseif {$input eq "from user to server command help message learn"   } {
      ::user::helpers::displayHelpForLearn
    } elseif {$input eq "from user to server command help message acts"    } {
      ::user::helpers::displayHelpForActs
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
  puts "##################################### help ####################################"
  puts ""
  puts "USER COMMANDS - BEHAVIOR"
  puts ""
  puts "help    ...   Displays a help screen containing a list of commands."
  puts "explore ...   get aquainted with the environment"
  puts "stop          stop all behavior, exploratory or otherwise"
  puts "do      ACTS  do a particular action or list of actions"
  puts "try     DATA  give Maestro a goal (flat)"
  puts "can     DATA  ask the system if it can achieve a goal"
  puts "sleep   ...   stop actions and process memory to generate intuition."
  puts ""
  puts "USER COMMANDS - PARAMETERS"
  puts ""
  puts "learn   ...   memorize and encode data or don't"
  puts "acts    ACTS  set list of available actions"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForHelp {} {
  puts ""
  puts "################################## help help ##################################"
  puts ""
  puts "help COMMAND    display help for specific commands"
  puts ""
  puts "Examples:"
  puts "help explore    display help about explore's 3 sub commands"
  puts "help help       display this message"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForEncode {} { ;# isn't used right now
  puts ""
  puts "################################## help encode ################################"
  puts ""
  puts "limit INT    sets the limit of learning; lower is faster. 1 - 10"
  puts "cells INT    sets the number of cells per node; 1 - 10. Not advised"
  puts "from user to s.1 message _ tells simulation to tell naisen its location"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}


proc ::user::helpers::displayHelpForExplore {} {
  puts ""
  puts "################################# help explore ################################"
  puts ""
  puts "explore random    explore the environment using random actions"
  puts "explore curious   explore the environment using unused actions"
  puts "explore off       stop exploring the environment"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}


proc ::user::helpers::displayHelpForStop {} {
  puts ""
  puts "################################## help stop ##################################"
  puts ""
  puts "stop    stops all behavior and has no subcommands"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForDo {} {
  puts ""
  puts "#################################### help do ##################################"
  puts ""
  puts "do ACT    do a particular action or list of actions right now"
  puts ""
  puts "Examples:"
  puts "do 1      do action number 1"
  puts "do 1 2 3  do this list of actions: 1 2 3"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForTry {} {
  puts ""
  puts "################################### help try ##################################"
  puts ""
  puts "try DATA    achieve the state of the environment that DATA represents"
  puts ""
  puts "Examples:"
  puts "try 123     achieve state 123 (numberline tutorial environment)"
  puts "try v1e30%  achieve state v1e30% in whatever environment you are in"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForCan {} {
  puts ""
  puts "################################### help can ##################################"
  puts ""
  puts "can DATA    see if you think you can achieve the state of the environment that"
  puts "            is indicated by DATA"
  puts ""
  puts "Examples:"
  puts "can 123     can you achieve state 123 (numberline tutorial)?"
  puts "can v1e30%  can you achieve v1e30% your current environment?"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}


proc ::user::helpers::displayHelpForSleep {} {
  puts ""
  puts "################################## help sleep #################################"
  puts ""
  puts "sleep         stop behaviors and perform the default list of simple analytics:"
  puts "              (acts and opps)"
  puts "sleep acts    discover a list of actions that have produced results and only"
  puts "              use those actions from now on to explore the environment"
  puts "sleep opps    produce a list of behaviors that have always produced the"
  puts "              opposite results and extrapolate those opposite actions into a"
  puts "              list of new predictions about how the environment behaves"
  puts "sleep react   reset its available actions to the default available actions"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}

proc ::user::helpers::displayHelpForLearn {} {
  puts ""
  puts "################################## help learn #################################"
  puts ""
  puts "learn       same as learn on"
  puts "learn on    while doing actions memorize and encode data"
  puts "learn off   do actions without memorizing or encoding data"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}


proc ::user::helpers::displayHelpForActs {} {
  puts ""
  puts "################################### help acts #################################"
  puts ""
  puts "acts ACTS   use this list of actions to affect the environment the command can"
  puts "            be used before Maestro explores the environment for efficiency"
  puts ""
  puts "Example:"
  puts "acts 1 2 3  limits Maestro's actions the listed three actisons"
  puts ""
  puts "##################################### end #####################################"
  puts ""
}



############################################################################
# Run ######################################################################
############################################################################


set ::chan [socket 127.0.0.1 9900]
::user::run
vwait forever
